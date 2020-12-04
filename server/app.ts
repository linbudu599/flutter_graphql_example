import express from "express";
import jsonGraphqlExpress from "json-graphql-server";

import chalk from "chalk";

const app = express();

interface IToDoItem {
  id: number;
  title: string;
  description: string;
  createDate: number;
  accomplished: boolean;
}

const data: { todos: IToDoItem[] } = {
  todos: [
    {
      id: 1,
      title: "Learn Flutter Basic",
      description: "Widget & Router & ... and so on",
      accomplished: false,
      createDate: Date.now(),
    },
    {
      id: 2,
      title: "Learn GraphQL Basic",
      description: "Operation & Resolver & ... and so on",
      accomplished: true,
      createDate: Date.now(),
    },
  ],
};

const PORT = process.env?.PORT ?? 4000;

app.use("/graphql", jsonGraphqlExpress(data));

app.listen(PORT, () => {
  console.log(
    chalk.green(`🍀 Server ready at http://localhost:${PORT}/graphql`)
  );
});
