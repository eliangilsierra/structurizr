import express from "express";
const app = express();
const port = process.env.PORT || 8080;

app.use("/", (req, res) => {
  res.redirect("/workspace?apiKey=abc123");
});

app.listen(port, () => {
  console.log(`Proxy listening at http://localhost:${port}`);
});
