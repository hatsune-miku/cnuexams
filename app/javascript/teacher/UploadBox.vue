<template>
    <div>
        <div class="center-screen" style="z-index: 4;">
            <div class="alertbox" style="z-index: 4;">
                <table style="width: 100%;">
                    <tr>
                        <td align="left">
                            <h3>{{windowTitle}}</h3>
                        </td>
                        <td align="right">
                            <el-button @click="onCancelled" circle type="text">
                                <i style="font-size: 24px; color: rgb(229, 116, 113);" class="el-icon-error"></i>
                            </el-button>
                        </td>
                    </tr>
                </table>

                <el-upload drag :action="`/upload/?db=${dbName}`" :on-error="onError" :on-success="onUploaded" :before-upload="beforeUpload">
                    <i class="el-icon-upload"></i>
                    <div class="el-upload__text">拖动文件或<em>点击上传</em></div>
                    <div class="el-upload__tip" slot="tip">请上传与表头对应的 xlsx 文档</div>
                </el-upload>
            </div>
        </div>
        <div class="alertback" style="z-index: 3;">
        </div>
    </div>
</template>

<script>
    export default {
        data: function () {
            return {
                windowTitle: ''
            };
        },
        props: {
            title: String,
            dbName: String,
            onCancelled: Function,
            onSuccess: Function
        },
        created() {
            this.windowTitle = this.title;
        },
        methods: {
            beforeUpload() {
                this.windowTitle = '服务器正在处理中';
                return true;
            },
            onError() {
                this.$notify({ type: 'error', message: '导入失败，很可能是因为数据存在重复，其次可能是因为服务器出了故障。' });
            },
            onUploaded() {
                this.$notify({ type: 'success', message: '导入完成' });
                this.windowTitle = '导入完成';
            }
        }
    };
</script>
