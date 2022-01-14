<script>
    import { connection, connectionState, ConnectionState } from "./store.js";
    import { fade } from "svelte/transition";
    import { onMount } from "svelte";

    let copied = false;
    let receivedText;
    let receivedFiles = [];

    // The following stuff is to show a "scroll to bottom" button when the user
    // receives data. Might be able to move it to separate component?
    let y;
    let receiveElement;
    let showScrollToBottom;

    $: receivedData = receivedText || receivedFiles.length > 0;
    $: showScrollToBottom =
        receiveElement && receivedData && !isReceiveVisible(y);

    onMount(() => {
        receiveElement = document.getElementById("receive-anchor");
    });

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

    function isReceiveVisible(y) {
        const rect = receiveElement.getBoundingClientRect();

        return (
            rect.top >= 0 &&
            rect.left >= 0 &&
            rect.bottom <=
                (window.innerHeight || document.documentElement.clientHeight) &&
            rect.right <=
                (window.innerWidth || document.documentElement.clientWidth)
        );
    }

    function scrollToReceive() {
        receiveElement.scrollIntoView({ behavior: "smooth" });
    }
</script>

<svelte:window bind:scrollY={y} />

<h2 class="text-center">Receive</h2>

<h5 id="receive-anchor">
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

{#if showScrollToBottom}
    <div class="scroll-to-receive" on:click={scrollToReceive}>
        <figure
            class="avatar avatar-lg py-2 bg-primary text-center badge"
            data-badge="!"
        >
            <i class="icon icon-arrow-down icon-2x" />
        </figure>
    </div>
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

    .scroll-to-receive {
        position: fixed;
        right: 1rem;
        bottom: 1rem;
    }

    .scroll-to-receive figure:hover {
        cursor: pointer;
    }

    .scroll-to-receive figure {
        box-shadow: 0 0 0 0 rgba(87, 85, 217, 1);
        transform: scale(1);
        animation: pulse 2s infinite;
    }

    /* https://www.florin-pop.com/blog/2019/03/css-pulse-effect/ <3 */
    @keyframes pulse {
        0% {
            transform: scale(0.95);
            box-shadow: 0 0 0 0 rgba(87, 85, 217, 0.7);
        }

        70% {
            transform: scale(1);
            box-shadow: 0 0 0 10px rgba(0, 0, 0, 0);
        }

        100% {
            transform: scale(0.95);
            box-shadow: 0 0 0 0 rgba(0, 0, 0, 0);
        }
    }
</style>
