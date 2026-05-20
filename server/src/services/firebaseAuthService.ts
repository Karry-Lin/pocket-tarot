import { getApps, initializeApp } from "firebase-admin/app";
import { getAuth, type DecodedIdToken } from "firebase-admin/auth";

export type DecodedFirebaseToken = {
  uid: string;
  email: string;
  emailVerified: boolean;
  providerIds: string[];
};

export interface FirebaseAuthService {
  verifyIdToken(token: string): Promise<DecodedFirebaseToken>;
}

export class FirebaseAdminAuthService implements FirebaseAuthService {
  async verifyIdToken(token: string): Promise<DecodedFirebaseToken> {
    if (getApps().length === 0) {
      initializeApp();
    }

    const decoded = await getAuth().verifyIdToken(token);
    return normalizeDecodedToken(decoded);
  }
}

function normalizeDecodedToken(decoded: DecodedIdToken): DecodedFirebaseToken {
  const signInProvider = decoded.firebase?.sign_in_provider;
  const providerIds = signInProvider ? [signInProvider] : [];

  return {
    uid: decoded.uid,
    email: decoded.email ?? "",
    emailVerified: decoded.email_verified === true,
    providerIds
  };
}
