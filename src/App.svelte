<script>
    import Connect from "./Connect.svelte";
    import Send from "./Send.svelte";
    import Receive from "./Receive.svelte";
    import { connectionState, ConnectionState } from "./store.js";
</script>

<main>
    <Connect />

    {#if $connectionState === ConnectionState.connected}
        <div class="columns">
            <div class="column col-md-12 panel-send-recv">
                <div class="panel py-2">
                    <div class="panel-body">
                        <Send />
                    </div>
                </div>
            </div>

            <div class="column panel-send-recv">
                <div class="panel py-2">
                    <div class="panel-body">
                        <Receive />
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

    .panel-send-recv .panel {
        height: 100%;
    }
</style>
