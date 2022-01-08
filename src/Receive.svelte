<script>
    import { connection, connectionState, ConnectionState } from "./store.js";
    import { fade } from "svelte/transition";

    let copied = false;
    let receivedData = "You have not received any data (yet!)";

    connectionState.subscribe((value) => {
        if (value !== ConnectionState.connected) {
            return;
        }

        $connection.on("data", (data) => {
            receivedData = data;
        });
    });

    // Adapted from https://stackoverflow.com/a/48542290
    function copyReceivedData() {
        navigator.clipboard.writeText(receivedData);

        copied = true;
        setTimeout(() => {
            copied = false;
        }, 300);
    }
</script>

<h2 class="text-center">Receive data</h2>
<p class="text-center">Data you receive will appear here.</p>
{#if receivedData}
    <div class="receive-container-wrapper">
        {#if copied}
            <span class="copy-ack text-tiny" out:fade>Copied!</span>
        {/if}
        <pre class="code receive-wrapper" on:click={copyReceivedData}><code
                class="p-relative"
                ><span class="copy-wrapper text-gray"
                    ><i class="icon icon-copy" /></span
                >{receivedData}
    </code></pre>
    </div>
{:else}
    <p class="text-center text-gray">You have not received any data (yet!)</p>
{/if}

<style>
    .copy-wrapper {
        position: absolute;
        right: 1px;
        top: 1px;
        padding: 5px 5px;
    }

    .receive-wrapper {
        white-space: pre-wrap;
    }

    .receive-wrapper:hover {
        cursor: pointer;
    }

    .receive-wrapper:hover .copy-wrapper {
        color: #3b4351 !important;
        cursor: pointer;
    }

    .receive-container-wrapper {
        position: relative;
    }

    .copy-ack {
        right: 0;
        top: -1.1rem;
        position: absolute;
    }
</style>
