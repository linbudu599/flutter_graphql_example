import Koa from "koa";
import fs from "fs";
import mount from "koa-mount";
import GraphQLHttpClient from "koa-graphql";
import { buildSchema } from "graphql";
import Logger from "koa-logger";
import chalk from "chalk";
import low from "lowdb";
import FileSync from "lowdb/adapters/FileSync";

// 重置数据
fs.unlinkSync("./db.json");

const adapter = new FileSync("./db.json");
const db = low(adapter);

interface ITodoItem {
  id: number;
  title: string;
  desc: string;
  accomplished: boolean;
}

db.defaults({
  items: [
    {
      id: 0,
      title: "TODO_1",
      desc: "DESC_1",
      accomplished: false,
    },
    {
      id: 1,
      title: "TODO_2",
      desc: "DESC_2",
      accomplished: false,
    },
  ] as ITodoItem[],
}).write();

const app = new Koa();

app.use(Logger());

const schema = buildSchema(`
  type Item {
    id: Int!
    title: String!
    desc: String!
    accomplished: Boolean!
  }
  type Query {
    todos: [Item!]
    getById(id: Int): Item
  }
  input ItemCreation {
    title: String!
    desc: String
  }
  type Mutation {
    addTodo(item: ItemCreation!): Item
    updateTodoStatus(id: Int!): Item
    deleteTodo(id: Int): Item
  }
`);

const rootResolver = {
  todos: () => db.getState().items,

  getById: ({ id }) => db.get("items").find({ id }).value(),

  addTodo: ({ item: { title, desc } }: { item: Partial<ITodoItem> }) => {
    const id = db.get("items").size().value();
    db.get("items").push({ id, title, desc, accomplished: false }).write();
    return db.get("items").find({ id }).value();
  },

  updateTodoStatus: ({ id }) => {
    const originalStatus: boolean = db.get("items").find({ id }).value()
      .accomplished;
    db.get("items")
      .find({ id })
      .assign({ accomplished: !originalStatus })
      .write();
    return db.get("items").find({ id }).value();
  },

  deleteTodo: ({ id }) => {
    const item = db.get("items").find({ id }).value();
    db.get("items").remove({ id }).write();
    return item;
  },
};

app.use(
  mount(
    "/graphql",
    GraphQLHttpClient({
      schema: schema,
      rootValue: rootResolver,
      graphiql: true,
      pretty: true,
    })
  )
);

app.listen(4000, () => {
  console.log(chalk.green("http://localhost:4000/graphql"));
});
