<template>
    <div>
        <div class="center-screen" style="z-index: 4;">
            <div class="alertbox" style="z-index: 4;" v-if="visibility">
                <p style="font-weight: bold; font-size: 16px;">{{message}}</p>
                <br/>
                <el-button id="buttonYes" @click.native="nativeOnYes" type="danger" size="mini" round autofocus>✓</el-button>
                <el-button @click.native="nativeOnNo" size="mini" round>✗</el-button>
            </div>
        </div>
        <div class="alertback" @click="nativeOnNo" style="z-index: 3;" v-if="visibility">
        </div>
    </div>
</template>

<style scoped>
    .alertbox {
        animation: bouncein ease 0.3s;
        padding: 20px 60px;
        box-shadow: black 0 0 1px;
        text-align: center;

        border-radius: 10px;

        background: white;
    }

    .alertback {
        animation: fadein linear 0.3s;

        position: fixed;

        opacity: 0.7;
        width: 100%;
        height: 100%;
        left: 0;
        top: 0;
        background: #1C1C1C;
    }

</style>

<script>
    export default {
        props: {
            visibility: {
                type: Boolean,
                default: false
            },
            message: {
                type: String,
                default: ''
            },
            onYes: {
                type: Function
            },
            onNo: {
                type: Function
            }
        },
        methods: {
            nativeOnYes() {
                if (this.onYes)
                    this.onYes();
            },
            nativeOnNo() {
                if (this.onNo)
                    this.onNo();
            }
        }
    }
</script>
