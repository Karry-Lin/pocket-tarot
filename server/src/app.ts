import cors from "cors";
import express, { type Express } from "express";
import helmet from "helmet";
import swaggerUi from "swagger-ui-express";

import { loadOpenApiDocument } from "./config/openApi.js";
import { errorHandler } from "./http/errorHandler.js";
import { createAdminRouter } from "./routes/adminRoutes.js";
import { createAuthRouter } from "./routes/authRoutes.js";
import { createDailyReadingRouter } from "./routes/dailyReadingRoutes.js";
import { createDeepReadingRouter } from "./routes/deepReadingRoutes.js";
import { createUserRouter } from "./routes/userRoutes.js";
import { buildAppDependencies, type AppOptions } from "./types/appDependencies.js";

export function createApp(options: AppOptions = {}): Express {
  const app = express();
  const openApiDocument = loadOpenApiDocument();
  const dependencies = buildAppDependencies(options);

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

  app.use("/api/v1/auth", createAuthRouter(dependencies));
  app.use("/api/v1/users", createUserRouter(dependencies));
  app.use("/api/v1/daily-readings", createDailyReadingRouter(dependencies));
  app.use("/api/v1/deep-readings", createDeepReadingRouter(dependencies));
  app.use("/api/v1/admin", createAdminRouter(dependencies));

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

  app.use(errorHandler);

  return app;
}
