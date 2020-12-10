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
      title: "NodeJS",
      desc: "NodeJS 多进程!",
      accomplished: false,
    },
    {
      id: 1,
      title: "Flutter",
      desc: "重学Flutter!",
      accomplished: false,
    },
    {
      id: 2,
      title: "GraphQL",
      desc: "领略另一种风景!",
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
    allTodos: [Item]!
    getById(id: Int!): Item
  }

  type Mutation {
    createTodo(title: String, desc: String): Item!
    updateTodo(id: Int!, title: String, desc: String): Item!
    toggleTodoStatus(id: Int!): Item!
    deleteTodo(id: Int!): Boolean!
  }
`);

// TODO: use more lodash api
const rootResolver = {
  allTodos: () => db.getState().items,

  getById: ({ id }) => db.get("items").find({ id }).value(),

  createTodo: ({ title, desc }: Partial<ITodoItem>) => {
    const id = db.get("items").size().value();
    db.get("items").push({ id, title, desc, accomplished: false }).write();
    return db.get("items").find({ id }).value();
  },

  updateTodo: ({ id, title, desc }: Partial<ITodoItem>) => {
    const original: ITodoItem = db.get("items").find({ id }).value();

    db.get("items")
      .find({ id })
      // FIXME: use more suitable method
      .assign({ title: title ?? original.title, desc: desc ?? original.desc })
      .write();
    return db.get("items").find({ id }).value();
  },

  toggleTodoStatus: ({ id }) => {
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
    return true;
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
