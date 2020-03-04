<template>
    <el-container direction="vertical" style="margin: 10px;">

        <table style="width: 80%;" class="hmiddle">
            <tr>
                <td style="width: 240px;">
                    <h4 style="color: gray;">对于所有理科学院</h4>

                    <el-input v-model="chartDataMath.rows[0].value">
                        <span slot="prepend">理科题比例</span>
                    </el-input>

                    <el-input v-model="chartDataMath.rows[1].value">
                        <span slot="prepend">文科题比例</span>
                    </el-input>

                    <el-input v-model="chartDataMath.rows[2].value">
                        <span slot="prepend">通用题比例</span>
                    </el-input>

                    <p>
                        <el-button size="medium" type="primary" :disabled="!validInput('math')"
                                   icon="el-icon-magic-stick" @click="actionOnekeyChange('math')">
                            一键更改
                        </el-button>
                    </p>
                </td>

                <td>
                    <!-- echarts is extremely stupid. -->
                    <ve-pie :legend="normalizedLegendSettings" :data="chartDataMath"></ve-pie>
                </td>
            </tr>
        </table>

        <el-divider direction="horizontal"/>

        <table style="width: 80%;" class="hmiddle">
            <tr>
                <td style="width: 240px;">
                    <h4 style="color: gray;">对于所有文科学院</h4>

                    <el-input v-model="chartDataArt.rows[0].value">
                        <span slot="prepend">理科题比例</span>
                    </el-input>

                    <el-input v-model="chartDataArt.rows[1].value">
                        <span slot="prepend">文科题比例</span>
                    </el-input>

                    <el-input v-model="chartDataArt.rows[2].value">
                        <span slot="prepend">通用题比例</span>
                    </el-input>

                    <p>
                        <el-button size="medium" type="primary" :disabled="!validInput('art')"
                                   icon="el-icon-magic-stick" @click="actionOnekeyChange('art')">
                            一键更改
                        </el-button>
                    </p>
                </td>

                <td>
                    <!-- echarts is extremely stupid. -->
                    <ve-pie :legend="normalizedLegendSettings" :data="chartDataArt"></ve-pie>
                </td>
            </tr>
        </table>


    </el-container>
</template>

<script>
    import axios from 'axios';

    export default {
        data: function () {
            return {
                chartDataMath: {
                    columns: ['kind', 'value'],
                    rows: [
                        { kind: '理科题', value: 0.3 },
                        { kind: '文科题', value: 0.3 },
                        { kind: '通用题', value: 0.4 }
                    ]
                },
                chartDataArt: {
                    columns: ['kind', 'value'],
                    rows: [
                        { kind: '理科题', value: 0.3 },
                        { kind: '文科题', value: 0.3 },
                        { kind: '通用题', value: 0.4 }
                    ]
                },
                // echarts is extremely stupid.
                normalizedLegendSettings: {
                    align: 'left',
                    orient: 'vertical',
                    left: 'right',
                    top: 'center'
                }
            };
        },
        created() {

        },
        methods: {
            validInput(kind) {
                if (kind === 'math') {
                    return Number(this.chartDataMath.rows[0].value)
                        + Number(this.chartDataMath.rows[1].value)
                        + Number(this.chartDataMath.rows[2].value)
                        === 1
                }
                else {
                    return Number(this.chartDataArt.rows[0].value)
                        + Number(this.chartDataArt.rows[1].value)
                        + Number(this.chartDataArt.rows[2].value)
                        === 1
                }
            },
            actionOnekeyChange(kind) {
                if (!this.validInput(kind)) {
                    this.$alert('文、理、综合三类题目比例相加应当为 1.', '错误');
                    return;
                }

                let _this = this;
                this.$confirm('确认要进行批量修改吗？<br/>这将覆盖各个学院的独立设置，并且此操作<strong>不可逆</strong>。', '警告⚠️', {
                    dangerouslyUseHTMLString: true,
                    confirmButtonText: '确认修改',
                    cancelButtonText: '取消',
                    type: 'warning'
                }).then(() => {
                    axios.post('/institutes/', {
                        intent: 'onekey-set',
                        kind: kind,
                        mathp: kind === 'math' ? this.chartDataMath.rows[0].value : this.chartDataArt.rows[0].value,
                        artp: kind === 'math' ? this.chartDataMath.rows[1].value : this.chartDataArt.rows[1].value,
                        generalp: kind === 'math' ? this.chartDataMath.rows[2].value : this.chartDataArt.rows[2].value
                    }).then(() => {
                        _this.$notify({ type: 'success', message: '批量设置完成' });
                    });
                }).catch(() => {});
            }
        }
    };
</script>
