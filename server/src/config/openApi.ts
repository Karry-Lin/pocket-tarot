import fs from "node:fs";
import path from "node:path";

import YAML from "yaml";

export type OpenApiDocument = Record<string, unknown>;

export function loadOpenApiDocument(): OpenApiDocument {
  const openApiPath = resolveOpenApiPath();
  const source = fs.readFileSync(openApiPath, "utf8");

  return YAML.parse(source) as OpenApiDocument;
}

function resolveOpenApiPath(): string {
  const candidates = [
    path.resolve(process.cwd(), "openapi", "openapi.yaml"),
    path.resolve(process.cwd(), "server", "openapi", "openapi.yaml")
  ];

  const found = candidates.find((candidate) => fs.existsSync(candidate));

  if (!found) {
    throw new Error(`OpenAPI file not found. Checked: ${candidates.join(", ")}`);
  }

  return found;
}
