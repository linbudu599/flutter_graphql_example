import express from "express";
import jsonGraphqlExpress from "json-graphql-server";
import chalk from "chalk";

const app = express();

interface IToDoItem {
  id: number;
  title: string;
  description: string;
  accomplished: boolean;
}

const data: { todos: IToDoItem[] } = {
  todos: [
    {
      id: 1,
      title: "Learn Flutter Basic",
      description: "Widget & Router & ... and so on",
      accomplished: false,
    },
    {
      id: 2,
      title: "Learn GraphQL Basic",
      description: "Operation & Scalar & ... and so on",
      accomplished: true,
    },
  ],
};

const PORT = process.env.PORT;

app.use("/graphql", jsonGraphqlExpress(data));

app.listen(PORT, () => {
  console.log(
    chalk.green(`🍀 Server ready at http://localhost:${PORT}/graphql`)
  );
});
