import App from './App.svelte';

document.getElementById('noJsFallback').remove();

const app = new App({
	target: document.getElementById('app'),
	props: {}
});

export default app;
