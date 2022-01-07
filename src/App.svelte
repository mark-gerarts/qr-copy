<script>
    import Connect from "./Connect.svelte";
    import { connectionState, ConnectionState } from "./store.js";
</script>

<header class="text-center">
    <h1 class="text-primary">QR+Copy</h1>
    <p>Transfer text & files between devices using P2P communication.</p>
</header>

<main>
    <Connect />

    {#if $connectionState === ConnectionState.connected}
        <div class="panel panel-send-recv">
            <div class="panel-body">
                <div class="columns my-2">
                    <div class="column col-sm-12">
                        <h2 class="text-center">Send data</h2>
                        <form>
                            <div class="form-group">
                                <label class="form-label" for="input-example-3"
                                    >Message</label
                                >
                                <textarea
                                    class="form-input"
                                    id="input-example-3"
                                    placeholder="Enter the text you want to send here"
                                    rows="3"
                                />
                            </div>
                            <button class="btn btn-primary">Send</button>
                        </form>
                    </div>
                    <div class="divider-vert" data-content="OR" />
                    <div class="column">
                        <h2 class="text-center">Receive data</h2>
                        <p class="text-center">
                            Data you receive will appear here.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    {/if}
</main>

<style>
    .panel-send-recv {
        margin-top: 16px;
    }
</style>
