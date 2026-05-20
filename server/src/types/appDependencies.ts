import { FirebaseAdminAuthService, type FirebaseAuthService } from "../services/firebaseAuthService.js";

export type AppDependencies = {
  adminApiKey: string;
  firebaseAuthService: FirebaseAuthService;
};

export type AppOptions = Partial<AppDependencies>;

export function buildAppDependencies(options: AppOptions = {}): AppDependencies {
  return {
    adminApiKey: options.adminApiKey ?? process.env.ADMIN_API_KEY ?? "",
    firebaseAuthService: options.firebaseAuthService ?? new FirebaseAdminAuthService()
  };
}
