<script>
    import Peer from "peerjs";
    import QrCode from "svelte-qrcode";

    export let myId;
    export let connectId;
    export let data = "Enter something here";

    let peer = new Peer();

    peer.on("open", (id) => {
        myId = id;
    });

    peer.on("connection", (connection) => {
        connection.on("data", (data) => {
            console.log("received data");
            console.log(data);
        });
    });

    export let sendData = () => {
        let connection = peer.connect(connectId);

        connection.on("open", () => {
            connection.send(data);
        });
    };
</script>

<main class="container is-max-desktop">
    <h1 class="is-size-1 has-text-danger">QR+Copy</h1>
    {#if myId}
        <p>My ID is {myId}</p>
        <QrCode value={myId} />

        <div class="field">
            <label class="label">ID to connect to</label>
            <div class="control">
                <input
                    class="input"
                    type="text"
                    placeholder="Text input"
                    bind:value={connectId}
                />
            </div>
        </div>

        <div class="field">
            <label class="label">Data to send</label>
            <div class="control">
                <input
                    class="input"
                    type="text"
                    placeholder="Text input"
                    id="data"
                    bind:value={data}
                />
            </div>
        </div>

        <button class="button" on:click={sendData}>Send data</button>
    {:else}
        <span class="button is-loading" />
    {/if}
</main>
