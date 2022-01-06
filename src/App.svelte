<script>
    // @todo: extract whatever's possible into separate components.
    import Peer from "peerjs";
    import QrCode from "svelte-qrcode";

    const ID_LENGTH = 8;

    const ConnectionState = {
        loading: "loading",
        connected: "connected",
        error: "error",
        invalidId: "invalidId",
    };

    let connectId = "";
    let connectionState;
    let connectionError;
    $: showFormError =
        connectionState === ConnectionState.error ||
        connectionState === ConnectionState.invalidId;

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

    peer.on("connection", (connection) => {
        connectionState = ConnectionState.connected;

        connection.on("data", (data) => {
            console.log("received data");
            console.log(data);
            console.log(peer);
        });
    });

    peer.on("error", (err) => {
        connectionError = err;
        connectionState = ConnectionState.error;
    });

    let connection;

    function connect(e) {
        e.preventDefault();

        if (connectionState === ConnectionState.loading) {
            return;
        }

        if (connectId.length !== ID_LENGTH) {
            connectionState = ConnectionState.invalidId;

            return;
        }

        connectionState = ConnectionState.loading;
        connection = peer.connect(connectId.toUpperCase());
        connection.on("open", () => {
            connectionState = ConnectionState.connected;
        });
    }
</script>

<header class="text-center">
    <h1 class="text-primary">QR+Copy</h1>
    <p>Transfer text & files between devices using P2P communication.</p>
</header>

<main>
    {#if connectionState !== ConnectionState.connected}
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
                            Scan this QR code on your other device, or enter
                            your ID manually.
                        </p>
                        <div class="id-box">{myId}</div>
                        <QrCode value={myId} />
                    </div>
                    <div class="divider-vert" data-content="OR" />
                    <div class="column">
                        <p>
                            Or scan your other device's QR code (todo) or enter
                            its ID manually.
                        </p>
                        <form class="flex-centered" on:submit={connect}>
                            <div
                                class="form-group"
                                class:has-error={showFormError}
                            >
                                <div class="input-group">
                                    <input
                                        class="form-input"
                                        placeholder="E.g. FC15C325"
                                        bind:value={connectId}
                                        class:is-error={showFormError}
                                        type="text"
                                        maxlength="8"
                                    />
                                    {#if connectionState === ConnectionState.loading}
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
                                {#if connectionState === ConnectionState.invalidId}
                                    <p class="form-input-hint">
                                        The ID has to be 8 characters long
                                    </p>
                                {:else if connectionState === ConnectionState.error}
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
    {:else}
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
    .id-box {
        font-family: "SF Mono", "Segoe UI Mono", "Roboto Mono", Menlo, Courier,
            monospace;
        font-weight: bold;
        font-size: 1.5rem;
        letter-spacing: 0.2rem;
        color: #000000;
    }

    .panel-send-recv {
        margin-top: 16px;
    }
</style>
