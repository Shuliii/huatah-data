const express = require("express");
const path = require("path");
const fs = require("fs").promises;

const app = express();
const PORT = 8080;

async function readFile(filePath) {
  try {
    const data = await fs.readFile(filePath, "utf8");
    return JSON.parse(data);
  } catch (error) {
    console.error(`Got an error trying to read the file: ${error.message}`);
  }
}

function filterData(data) {
  const now = new Date();
  const filteredData = data.filter((item) => {
    const matchTime = new Date(item.time);
    return matchTime - now > 0;
  });

  return filteredData;
}

app.get("/api/:name", async (req, res) => {
  try {
    const result = path.join(__dirname, `/data/${req.params.name}.json`);
    const data = await readFile(result);
    const filteredData = filterData(data);
    res.json({ data: filteredData });
  } catch (error) {
    console.log("error", error);
    res.status(500).json({ message: "Internal Server Error" });
  }
});

app.listen(PORT, () => {
  console.log(`The server it's running on ${PORT}`);
});
