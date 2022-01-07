<script>
    import Connect from "./Connect.svelte";
    import Send from "./Send.svelte";
    import Receive from "./Receive.svelte";
    import { connectionState, ConnectionState } from "./store.js";
</script>

<main>
    <Connect />

    {#if $connectionState === ConnectionState.connected}
        <div class="panel panel-send-recv">
            <div class="panel-body">
                <div class="columns my-2">
                    <div class="column col-sm-12">
                        <Send />
                    </div>
                    <div class="divider-vert hide-sm" data-content="OR" />
                    <div class="column">
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
</style>
