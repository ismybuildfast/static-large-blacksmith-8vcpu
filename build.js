const gen = require("hyperid")({ urlSafe: true });
const del = require("del").sync;
const { join } = require("path");
const { writeFileSync: write, mkdirSync: mkdir } = require("fs");

const OUT_DIR = join(__dirname, "public/files");
const MAX_FILES = 10000;

del(OUT_DIR);
mkdir(OUT_DIR);

const files = [];

for (let i = 0; i < MAX_FILES; i++) {
  const rand = gen() + ".html";
  write(join(OUT_DIR, rand), `<h1>${rand}</h1>`);
  files.push(rand);
  process.stdout.write(".");
}

write(
  join(OUT_DIR, "index.html"),
  `<!doctype html>
<h1>List of built files</h1>
<style>
  * { margin: 0; padding: 0; }

  body {
    max-width: 900px;
    padding: 20px;
  }

  ul {
    column-count: 3;
    list-style: none;
  }

  ul li {
    display: inline-block;
  }
</style>
<ul>
  ${files.map(file => `<li><a href="${file}">${file}</a></li>`).join("")}
</ul>
`
);