import App from './App.svelte';

const app = new App({
	target: document.body,
	props: {
		myId: undefined,
		connectId: undefined
	}
});

export default app;
