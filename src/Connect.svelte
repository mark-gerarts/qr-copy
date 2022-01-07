<script>
    import Peer from "peerjs";
    import QrCode from "svelte-qrcode";
    import { connection, connectionState, ConnectionState } from "./store.js";

    const ID_LENGTH = 8;

    let connectId;
    let showFormError;
    let connectionError;

    $: showFormError =
        $connectionState === ConnectionState.error ||
        $connectionState === ConnectionState.invalidId;

    let myId = (() => {
        // https://stackoverflow.com/a/27747377
        function dec2hex(dec) {
            return dec.toString(16).padStart(2, "0");
        }

        var arr = new Uint8Array((ID_LENGTH || 40) / 2);
        window.crypto.getRandomValues(arr);

        return Array.from(arr, dec2hex).join("").toUpperCase();
    })();

    let peer = new Peer(myId);

    peer.on("connection", initializeConnection);
    peer.on("error", onPeerError);
    peer.on("disconnected", onDisconnect);

    function connect(e) {
        e.preventDefault();

        if (connectionState === ConnectionState.loading) {
            return;
        }

        if (connectId.toUpperCase() === myId) {
            connectionState.set(ConnectionState.invalidId);
            connectionError =
                "Enter the ID of your other device, not this one!";

            return;
        }

        if (connectId.length !== ID_LENGTH) {
            connectionState.set(ConnectionState.invalidId);
            connectionError = "The ID has to be 8 characters long.";

            return;
        }

        connectionState.set(ConnectionState.loading);

        let connection = peer.connect(connectId.toUpperCase());
        initializeConnection(connection);
    }

    function onPeerError(error) {
        connectionState.set(ConnectionState.error);
        connectionError = error;
    }

    function onDisconnect() {
        connectionState.set(ConnectionState.disconnected);
    }

    function initializeConnection(incomingConnection) {
        connection.set(incomingConnection);

        incomingConnection.on("open", () => {
            connectionState.set(ConnectionState.connected);
        });

        incomingConnection.on("error", onDisconnect);
        incomingConnection.on("close", onDisconnect);
    }
</script>

{#if $connectionState === ConnectionState.connected}
    <div class="panel">
        <div class="panel-header text-center">
            <figure class="avatar avatar-lg py-2 bg-success">
                <i class="icon icon-check icon-2x" />
            </figure>
            <h2 class="h5 py-2">Successfully connected</h2>
        </div>
        <div class="panel-body text-center">
            <p class="text-tiny text-gray">
                Your ID: {myId}. Connected to: ABCD1234. Refresh the page to
                connect to a new device.
            </p>
        </div>
    </div>
{:else if $connectionState === ConnectionState.disconnected}
    <div class="panel">
        <div class="panel-header text-center">
            <figure class="avatar avatar-lg py-2 bg-error">
                <i class="icon icon-cross icon-2x" />
            </figure>
            <h2 class="h5 py-2">Disconnected</h2>
        </div>
        <div class="panel-body text-center">
            <p class="text-tiny text-gray">
                Something went wrong. <a href="./">Refresh the page</a> to try again.
            </p>
        </div>
    </div>
{:else}
    <div class="panel">
        <div class="panel-header text-center">
            <figure class="avatar avatar-lg py-2">
                <i class="icon icon-link icon-2x" />
            </figure>
            <h2 class="h5 py-2">Connect to another device</h2>
        </div>
        <div class="panel-body text-center">
            <div class="columns">
                <div class="column">
                    <p>
                        Scan this QR code on your other device, or enter your ID
                        manually.
                    </p>
                    <div class="id-box">{myId}</div>
                    <QrCode value={myId} />
                </div>
                <div class="divider-vert" data-content="OR" />
                <div class="column">
                    <p>
                        Or scan your other device's QR code (todo) or enter its
                        ID manually.
                    </p>
                    <form class="flex-centered" on:submit={connect}>
                        <div class="form-group" class:has-error={showFormError}>
                            <div class="input-group">
                                <input
                                    class="form-input"
                                    placeholder="E.g. FC15C325"
                                    bind:value={connectId}
                                    class:is-error={showFormError}
                                    type="text"
                                    maxlength="8"
                                />
                                {#if $connectionState === ConnectionState.loading}
                                    <button
                                        class="btn btn-primary input-group-btn loading"
                                        >Connect</button
                                    >
                                {:else}
                                    <button
                                        class="btn btn-primary input-group-btn"
                                    >
                                        Connect
                                    </button>
                                {/if}
                            </div>
                            {#if $connectionState === ConnectionState.invalidId}
                                <p class="form-input-hint">
                                    {connectionError}
                                </p>
                            {:else if $connectionState === ConnectionState.error}
                                <p class="form-input-hint">
                                    {connectionError}
                                </p>
                            {/if}
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
{/if}

<style>
    .id-box {
        font-family: "SF Mono", "Segoe UI Mono", "Roboto Mono", Menlo, Courier,
            monospace;
        font-weight: bold;
        font-size: 1.5rem;
        letter-spacing: 0.2rem;
        color: #000000;
    }
</style>
