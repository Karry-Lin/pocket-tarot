import { FirebaseAdminAuthService, type FirebaseAuthService } from "../services/firebaseAuthService.js";
import { ChatCompletionsLlmService, type LlmService } from "../services/llmService.js";
import { OpenMeteoWeatherService, type WeatherService } from "../services/weatherService.js";

export type AppDependencies = {
  adminApiKey: string;
  firebaseAuthService: FirebaseAuthService;
  llmService: LlmService;
  weatherService: WeatherService;
};

export type AppOptions = Partial<AppDependencies>;

export function buildAppDependencies(options: AppOptions = {}): AppDependencies {
  return {
    adminApiKey: options.adminApiKey ?? process.env.ADMIN_API_KEY ?? "",
    firebaseAuthService: options.firebaseAuthService ?? new FirebaseAdminAuthService(),
    llmService: options.llmService ?? new ChatCompletionsLlmService(),
    weatherService: options.weatherService ?? new OpenMeteoWeatherService()
  };
}
