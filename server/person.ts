import express from "express";
import jsonGraphqlExpress from "json-graphql-server";
import chalk from "chalk";

const app = express();

interface IPerson {
  id: number;
  name: string;
  age: number;
}

const data: { persons: IPerson[] } = {
  persons: [
    {
      id: 1,
      name: "林不渡",
      age: 21,
    },
    {
      id: 2,
      name: "穹心",
      age: 18,
    },
  ],
};

const PORT = 4000;

app.use("/graphql", jsonGraphqlExpress(data));

app.listen(PORT, () => {
  console.log(
    chalk.green(`🍀 Server ready at http://localhost:${PORT}/graphql`)
  );
});
