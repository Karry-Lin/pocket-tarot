import cors from "cors";
import express, { type Express } from "express";
import helmet from "helmet";
import swaggerUi from "swagger-ui-express";

import { loadOpenApiDocument } from "./config/openApi.js";

export function createApp(): Express {
  const app = express();
  const openApiDocument = loadOpenApiDocument();

  app.disable("x-powered-by");
  app.use(helmet({ contentSecurityPolicy: false }));
  app.use(cors());
  app.use(express.json({ limit: "1mb" }));

  app.get("/healthz", (_request, response) => {
    response.json({
      data: {
        status: "ok"
      }
    });
  });

  app.get("/docs.json", (_request, response) => {
    response.json(openApiDocument);
  });

  app.use(
    "/docs",
    swaggerUi.serve,
    swaggerUi.setup(openApiDocument, {
      customSiteTitle: "Pocket Tarot API Docs",
      swaggerOptions: {
        url: "/docs.json"
      }
    })
  );

  app.use((_request, response) => {
    response.status(404).json({
      error: {
        code: "NOT_FOUND",
        message: "找不到資源",
        details: {}
      }
    });
  });

  return app;
}
