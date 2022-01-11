<script>
    import { connection } from "./store.js";

    let text;
    let files;

    let sendingText = false;
    let sendingTextSuccessful = false;

    let sendingFiles = false;
    let sendingFilesSuccessful = false;

    function sendText(e) {
        e.preventDefault();

        sendingText = true;
        sendingTextSuccessful = false;

        $connection.send({
            type: "text",
            data: text,
        });

        sendingText = false;
        sendingTextSuccessful = true;
    }

    async function sendFiles() {
        sendingFiles = true;
        sendingFilesSuccessful = false;

        const filesArray = Array.from(files).map((file) => {
            return file.arrayBuffer().then((buffer) => {
                return {
                    blob: new Blob([new Uint8Array(buffer)], {
                        type: file.type,
                    }),
                    type: file.type,
                    name: file.name,
                };
            });
        });

        let mappedFiles;
        await Promise.all(filesArray).then((files) => (mappedFiles = files));

        $connection.send({
            type: "files",
            data: mappedFiles,
        });

        sendingFiles = false;
        sendingFilesSuccessful = true;
    }
</script>

<h2 class="text-center">Send</h2>
<div class="form-group">
    <label class="form-label" for="sendFileInput">
        File
        {#if sendingFiles}
            <span class="loading loading-send" />
        {/if}
        {#if sendingFilesSuccessful}
            <i class="icon icon-check text-success send-success" />
        {/if}
    </label>
    <input
        class="form-input"
        id="sendFileInput"
        type="file"
        bind:files
        on:change={sendFiles}
        multiple
    />
</div>

<div class="divider text-center" data-content="OR" />
<div class="form-group py-bottom-2">
    <label class="form-label" for="sendMessageInput"
        >Message
        {#if sendingText}
            <span class="loading loading-send" />
        {/if}
        {#if sendingTextSuccessful}
            <i class="icon icon-check text-success send-success" />
        {/if}
    </label>
    <textarea
        class="form-input"
        id="sendMessageInput"
        placeholder="Enter the text you want to send here"
        rows="3"
        bind:value={text}
        on:input={sendText}
    />
</div>

<style>
    .loading-send {
        margin-left: 0.75rem;
    }

    .send-success {
        margin-left: 0.25rem;
    }

    .divider {
        margin-top: 32px;
    }

    .py-bottom-2 {
        margin-bottom: 0.4rem;
    }
</style>
