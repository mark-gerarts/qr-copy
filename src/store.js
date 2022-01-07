import { writable } from "svelte/store";

export const ConnectionState = {
    notInitialized: "notInitialized",
    loading: "loading",
    connected: "connected",
    error: "error",
    invalidId: "invalidId",
    disconnected: "disconnected",
};

export const connectionState = writable(ConnectionState.notInitialized);

export const connection = writable(null);
