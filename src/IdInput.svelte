<script>
    import {
        connectionError,
        connectionState,
        ConnectionState,
    } from "./store.js";
    import { createEventDispatcher } from "svelte";
    import { Html5Qrcode, Html5QrcodeSupportedFormats } from "html5-qrcode";

    const ID_LENGTH = 8;

    export let myId;
    let connectId;
    let showFormError;
    let openModal = false;
    let scanningFailed = false;

    const dispatch = createEventDispatcher();

    $: showFormError =
        $connectionState === ConnectionState.error ||
        $connectionState === ConnectionState.invalidId;

    $: inputDisabled =
        $connectionState === ConnectionState.loading ||
        $connectionState === ConnectionState.awaitingConfirm;

    function onSubmit(e) {
        if (e) {
            e.preventDefault();
        }

        if (inputDisabled) {
            return;
        }

        if (!validateEnteredId()) {
            return;
        }

        dispatch("idInputReceived", {
            id: connectId,
        });
    }

    function startScanning() {
        if (inputDisabled) {
            return;
        }

        openModal = true;
        scanningFailed = false;

        initScanner();
    }

    function closeModalOnEscape(event) {
        if (event.keyCode === 27) {
            openModal = false;
        }
    }

    function closeModalIfClickedOutside(event) {
        if (!openModal) {
            return;
        }

        if (!event.target.closest(".in-modal")) {
            openModal = false;
        }
    }

    function initScanner() {
        const html5QrCode = new Html5Qrcode("reader", {
            formatsToSupport: [Html5QrcodeSupportedFormats.QR_CODE],
        });

        const qrCodeSuccessCallback = (decodedText) => {
            html5QrCode.stop().then(() => {
                openModal = false;
                connectId = parseConnectId(decodedText);
                onSubmit(null);
            });
        };

        const startFailedCallback = (errorMessage) => {
            scanningFailed = true;
        };

        const cameraConfig = { facingMode: "environment" };
        const config = { fps: 10, qrbox: { width: 250, height: 250 } };

        html5QrCode
            .start(cameraConfig, config, qrCodeSuccessCallback)
            .catch(startFailedCallback);
    }

    function parseConnectId(text) {
        return /(?!q=)\w{8}/.exec(text)[0];
    }

    function validateEnteredId() {
        if (!connectId || connectId.length !== ID_LENGTH) {
            $connectionState = ConnectionState.invalidId;
            $connectionError = "The ID has to be 8 characters long.";

            return false;
        }

        if (connectId.toUpperCase() === myId) {
            $connectionState = ConnectionState.invalidId;
            $connectionError =
                "Enter the ID of your other device, not this one!";

            return false;
        }

        return true;
    }
</script>

<svelte:window
    on:keydown={closeModalOnEscape}
    on:click={closeModalIfClickedOutside}
/>

<form on:submit={onSubmit}>
    <div class="form-group" class:has-error={showFormError}>
        <div class="input-group">
            <span
                class="input-group-addon btn-scan in-modal"
                on:click={startScanning}
            >
                <img src="./qr-code.png" alt="Start scanning" />
            </span>
            <input
                class="form-input"
                placeholder="E.g. FC15C325"
                bind:value={connectId}
                class:is-error={showFormError}
                type="text"
                maxlength="8"
                id="manualIdInput"
            />
            {#if $connectionState === ConnectionState.loading || $connectionState === ConnectionState.awaitingConfirm}
                <button class="btn btn-primary input-group-btn loading"
                    >Connect</button
                >
            {:else}
                <button class="btn btn-primary input-group-btn">
                    Connect
                </button>
            {/if}
        </div>
        {#if $connectionState === ConnectionState.invalidId}
            <p class="form-input-hint">
                {$connectionError}
            </p>
        {:else if $connectionState === ConnectionState.error}
            <p class="form-input-hint">
                {$connectionError}
            </p>
        {:else if $connectionState === ConnectionState.awaitingConfirm}
            <p class="form-input-hint text-gray">
                Awaiting confirmation from other device.
            </p>
        {/if}
    </div>
</form>

<div class="modal" id="modal-id" class:active={openModal}>
    <a href="#close" class="modal-overlay" aria-label="Close" />
    <div class="modal-container">
        <div class="modal-header">
            <a
                href="#close"
                class="btn btn-clear float-right"
                aria-label="Close"
            />
            <div class="modal-title h5 in-modal">Scan QR code</div>
        </div>
        <div class="modal-body in-modal">
            <div class="content">
                <div id="reader" />
                {#if scanningFailed}
                    <p class="text-error">
                        Could not start the QR code scanner. Try entering the
                        other device's ID manually instead!
                    </p>
                {/if}
            </div>
        </div>
    </div>
</div>

<style>
    .btn-scan:hover {
        cursor: pointer;
    }

    .btn-scan {
        display: flex;
        justify-content: center;
    }

    .btn-scan img {
        height: 24px;
    }
</style>
