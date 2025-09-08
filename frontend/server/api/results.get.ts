import { promises as fs } from 'node:fs';
import { resolve } from 'node:path';

export default defineEventHandler(async () => {
  const projectRoot = process.cwd();
  const filePath = resolve(projectRoot, '..', 'catbench', 'results.json');

  const fileContents = await fs.readFile(filePath, 'utf-8');
  const data = JSON.parse(fileContents);
  return data;
});


