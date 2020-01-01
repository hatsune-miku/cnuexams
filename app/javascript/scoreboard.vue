<template>
    <div>
        <div class="center-screen" style="z-index: 4;">
            <div class="alertbox" style="z-index: 4;" v-if="visibility">

                <h3>考试成绩</h3>

                <el-table :data="data" width="fit-content" :show-header="false">
                    <el-table-column prop="key" label="属性" width="90px"/>
                    <el-table-column prop="value" label="值" width="200px"/>
                </el-table>

                <p>
                    <el-button @click.native="nativeOnNo" type="primary" style="width: 200px;" size="medium">好</el-button>
                </p>
            </div>
        </div>
        <div class="alertback" style="z-index: 3;" v-if="visibility">
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
            data: {
                type: Array
            },
            visibility: {
                type: Boolean
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
