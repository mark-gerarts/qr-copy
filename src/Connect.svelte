<script>
    import Peer from "peerjs";
    import QrCode from "svelte-qrcode";
    import {
        connectionError,
        connection,
        connectionState,
        ConnectionState,
    } from "./store.js";
    import IdInput from "./IdInput.svelte";

    const ID_LENGTH = 8;

    let myId = generateRandomId();
    let connectId;
    let incomingPeerId;

    let peer = new Peer(myId);

    // This handler is triggered when another peer tries to connect to us. In
    // this case we let the user Accept or Decline the incoming connection.
    peer.on("connection", onIncomingConnection);

    peer.on("error", onPeerError);
    peer.on("disconnected", onDisconnect);

    // This gets triggered when we try to connect to someone else ourselves.
    function connect(e) {
        connectId = e.detail.id;

        $connectionState = ConnectionState.loading;

        let newConnection = peer.connect(connectId.toUpperCase());

        addErrorHandlers(newConnection);

        newConnection.on("open", () => {
            $connectionState = ConnectionState.awaitingConfirm;
        });

        newConnection.on("data", (data) => {
            if (
                typeof data !== "object" ||
                data.type === undefined ||
                data.type !== "ctrl_msg"
            ) {
                return;
            }

            if (data.data === "ack") {
                $connectionState = ConnectionState.connected;
                $connection = newConnection;
            }
            if (data.data === "decline") {
                $connectionState = ConnectionState.error;
                $connectionError = "The other device declined your request.";
            }
        });
    }

    function onIncomingConnection(incomingConnection) {
        incomingPeerId = incomingConnection.peer;
        $connection = incomingConnection;
        $connectionState = ConnectionState.authorizeConnection;
        addErrorHandlers(incomingConnection);
    }

    function onPeerError(error) {
        $connectionState = ConnectionState.error;
        $connectionError = error;
    }

    function onDisconnect() {
        $connectionState = ConnectionState.disconnected;
    }

    function addErrorHandlers(incomingConnection) {
        incomingConnection.on("error", onDisconnect);
        incomingConnection.on("close", onDisconnect);
    }

    function acceptConnection() {
        $connection.send(controlMessage("ack"));

        $connectionState = ConnectionState.connected;
    }

    function declineConnection() {
        $connection.send(controlMessage("decline"));

        $connectionState = ConnectionState.notInitialized;
        $connection = null;
        incomingPeerId = null;
    }

    function controlMessage(data) {
        return {
            type: "ctrl_msg",
            data: data,
        };
    }

    function generateRandomId() {
        // https://stackoverflow.com/a/27747377
        function dec2hex(dec) {
            return dec.toString(16).padStart(2, "0");
        }

        var arr = new Uint8Array((ID_LENGTH || 40) / 2);
        window.crypto.getRandomValues(arr);

        return Array.from(arr, dec2hex).join("").toUpperCase();
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
                Your ID: {myId}. Connected to: {connectId ? connectId : incomingPeerId}. Refresh the page to
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
{:else if $connectionState === ConnectionState.authorizeConnection}
    <div class="panel">
        <div class="panel-header text-center">
            <figure class="avatar avatar-lg py-2">
                <i class="icon icon-link icon-2x" />
            </figure>
            <h2 class="h5 py-2">Incoming connection from {incomingPeerId}</h2>
        </div>
        <div class="panel-body text-center py-2">
            <div class="columns">
                <div class="column col-md-2" />
                <div class="column col-md-4">
                    <button
                        class="btn btn-lg btn-success"
                        on:click={acceptConnection}>Accept</button
                    >
                </div>
                <div class="column col-md-4">
                    <button
                        class="btn btn-lg btn-error"
                        on:click={declineConnection}>Decline</button
                    >
                </div>
                <div class="column col-md-2" />
            </div>
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
        <div class="panel-body py-2">
            <div class="columns">
                <div class="column col-md-12 col-10 col-mx-auto">
                    <div class="columns">
                        <div class="column col-6 col-sm-12 text-center">
                            <p>
                                Open this webpage on both devices. Connect to
                                your other device by scanning its QR code or
                                entering its ID manually.
                            </p>
                            <IdInput bind:myId on:idInputReceived={connect} />
                        </div>
                        <div
                            class="column col-4 col-sm-12 col-ml-auto text-center"
                        >
                            <div class="spacer-y show-sm" />
                            <div class="id-box">{myId}</div>
                            <QrCode value={myId} />
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="panel-footer" />
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

    .spacer-y {
        margin-top: 2rem;
    }
</style>
