<script>
    import { connection, connectionState, ConnectionState } from "./store.js";
    import { fade } from "svelte/transition";

    let copied = false;
    let receivedText;
    let receivedFiles = [];

    connectionState.subscribe((value) => {
        if (value !== ConnectionState.connected) {
            return;
        }

        $connection.on("data", (data) => {
            if (data.type === "text") {
                receivedText = data.data;
            }
            if (data.type === "files") {
                receivedFiles = data.data.map(parseFileData);
            }
        });
    });

    function parseFileData(file) {
        return {
            blob: new Blob([new Uint8Array(file.blob)], {
                type: file.type,
            }),
            type: file.type,
            name: file.name,
        };
    }

    function copyReceivedText() {
        navigator.clipboard.writeText(receivedText);

        copied = true;
        setTimeout(() => {
            copied = false;
        }, 300);
    }
</script>

<h2 class="text-center">Receive</h2>

<h5>
    <figure class="avatar text-center bg-primary py-1">
        <i class="icon icon-download" />
    </figure>
    Files
</h5>

{#if receivedFiles.length > 0}
    <p>
        {#each receivedFiles as file}
            <a
                href={URL.createObjectURL(file.blob)}
                download={file.name}
                class="chip">{file.name}</a
            >
        {/each}
    </p>
{:else}
    <p class="text-gray offset-avatar">Files you receive will appear here.</p>
{/if}

<h5>
    <figure class="avatar text-center bg-primary py-1">
        <i class="icon icon-mail" />
    </figure>
    Messages
</h5>

{#if receivedText}
    <div class="receive-container-wrapper">
        {#if copied}
            <span class="copy-ack text-tiny" out:fade>Copied!</span>
        {/if}
        <pre class="code receive-wrapper" on:click={copyReceivedText}><code
                class="p-relative"
                ><span class="copy-wrapper text-gray"
                    ><i class="icon icon-copy" /></span
                >{receivedText}
    </code></pre>
    </div>
{:else}
    <p class="text-gray">You have not received any data yet.</p>
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
