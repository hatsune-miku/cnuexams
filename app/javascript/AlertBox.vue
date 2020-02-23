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
