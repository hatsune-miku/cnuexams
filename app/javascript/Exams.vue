<template>
    <div>
        <div style="left: 50%; text-align: left;">
            <table style="width: 90%;">
                <tr>
                    <td align="left"><h1>{{authCode ? '考试列表 (使用授权码)' : '考试列表'}}</h1></td>
                    <td align="right"><el-button type="text" size="medium" @click="actionUseAuthCode">
                        {{authCode ? '清空授权码' : '使用授权码'}}
                    </el-button></td>
                </tr>
            </table>

            <el-table :data="examsData" style="border-radius: 5px; width: 90%;"
                      :header-cell-style="tableTransparentApplier" :row-style="tableTransparentApplier"
                      :empty-text="emptyText"
                      v-loading="loading"
                      element-loading-text="Now Loading..."
                      element-loading-spinner="el-icon-loading"
                      element-loading-background="rgba(0, 0, 0, 0.8)">
                <el-table-column prop="id" label="ID" width="60px"/>

                <el-table-column prop="name" label="考试名称" width="200px"/>
                <el-table-column prop="time_limit" label="考试时间" width="160px">
                    <span slot-scope="scope">
                        {{secondTranslate(scope.row.time_limit)}}
                    </span>
                </el-table-column>

                <el-table-column prop="requirement" label="及格线" width="90px">
                    <template slot-scope="scope">
                        {{scope.row.requirement}} 分
                    </template>
                </el-table-column>

                <el-table-column prop="retestable" label="通过后可再考？">
                    <template slot-scope="scope">
                        {{scope.row.retestable === 1 ? 'Yes' : 'No'}}
                    </template>
                </el-table-column>

                <el-table-column prop="policy" label="若考多次，如何确定成绩？">
                    <template slot-scope="scope">
                        {{
                        ['以最后一次为准', '以最高分为准', '以最低分为准', '取平均'][scope.row.policy]
                        }}
                    </template>
                </el-table-column>

                <el-table-column fixed="right" width="120px">
                    <span slot-scope="scope">
                        <el-button size="mini"
                                   @click="actionSelectExam(scope.row.id, scope.row.name)"
                                   round>参加考试</el-button>
                    </span>
                </el-table-column>
            </el-table>
        </div>

        <alert-box :visibility="visibility" :message="message" :on-yes="actionAttend" :on-no="actionCancel"/>
    </div>
</template>

<script>
    import axios from 'axios';
    import AlertBox from "./AlertBox";

    export default {
        components: { AlertBox },
        data: function () {
            return {
                username: '',
                name: '',
                emptyText: '目前没有开放的考试',
                examsData: [],
                visibility: false,
                message: '',
                targetExamId: -1,
                givenMajor: null,
                loading: true,
                authCode: null
            };
        },
        mounted() {
            this.username = this.$cookies.get('username');
            axios.post('/exams/', {
                intent: 'list',
                username: this.username
            }).then(res => {
                if (res.data.errorcode !== 0) {
                    return;
                }
                this.examsData = res.data.response
            }).finally(() => {
                this.loading = false;
            });
        },
        methods: {
            tableTransparentApplier() {
                return 'background-color: #FCFAF2;';
            },
            actionSelectExam(id, name) {
                this.targetExamId = id;
                if (name.includes('(理科)'))
                    this.givenMajor = 0;
                else if (name.includes('(文科)'))
                    this.givenMajor = 1;
                else
                    this.givenMajor = null;

                this.message = "确认参加「" + name + "」考试吗？";
                this.visibility = true;
            },
            actionAttend() {
                let sessionId = this.$cookies.get('session');

                axios.post('/exams/', {
                    intent: 'start',
                    given_major: this.givenMajor,
                    session_id: sessionId,
                    exam_id: this.targetExamId,
                    auth_code: this.authCode,
                    username: this.username
                })
                .then(res => {
                    if (res.data.errorcode !== 0) {

                        if (res.data.message.includes('连续不及格')) {
                            this.$alert(res.data.message, 'CNU Exams', {
                                confirmButtonText: '好',
                                dangerouslyUseHTMLString: true
                            });
                        }
                        else {
                            this.$notify({ type: 'error', message: res.data.message });
                        }

                        this.visibility = false;
                        return;
                    }

                    this.reinitUserData();
                    this.$router.push('/overview/aoligei');
                });
            },
            actionCancel() {
                this.visibility = false;
            },
            actionUseAuthCode() {
                if (this.authCode) {
                    this.authCode = null;
                }
                else {
                    this.$prompt('输入授权码', 'CNU Exams', {
                        confirmButtonText: '好',
                        cancelButtonText: '取消',
                    }).then(({ value }) => {
                        this.authCode = value;
                    }).catch(() => {
                        this.authCode = null;
                    });
                }
            }
        }
    };
</script>
