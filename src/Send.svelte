<script>
    import { connection } from "./store.js";

    let dataToSend;

    function sendData(e) {
        e.preventDefault();

        $connection.send(dataToSend);
    }
</script>

<h2 class="text-center">Send data</h2>
<form on:submit={sendData}>
    <div class="form-group">
        <label class="form-label" for="input-example-3"> Message </label>
        <textarea
            class="form-input"
            id="input-example-3"
            placeholder="Enter the text you want to send here"
            rows="3"
            bind:value={dataToSend}
        />
    </div>
    <button class="btn btn-primary">Send</button>
</form>
