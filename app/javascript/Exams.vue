<template>
    <div>
        <div style="left: 50%; text-align: left;">
            <h1>考试列表</h1>
            <el-table :data="examsData" style="border-radius: 5px; width: 80%;"
                      :header-cell-style="tableTransparentApplier" :row-style="tableTransparentApplier"
                      :empty-text="emptyText">
                <el-table-column prop="id" label="ID" width="60px"/>

                <el-table-column prop="name" label="考试名称" width="200px"/>

                <el-table-column prop="requirement" label="及格线" width="130px">
                    <template slot-scope="scope">
                        {{scope.row.requirement}} 分
                    </template>
                </el-table-column>

                <el-table-column prop="retestable" label="通过后可再考？">
                    <template slot-scope="scope">
                        {{scope.row.retestable === 1 ? 'Yes' : 'No'}}
                    </template>
                </el-table-column>

                <el-table-column>
                    <template slot-scope="scope">
                        <el-button size="mini"
                                   @click="actionSelectExam(scope.row.id, scope.row.name)"
                                   round>参加考试</el-button>
                    </template>
                </el-table-column>
            </el-table>
        </div>

        <alert-box :visibility="visibility" :message="message" :on-yes="actionAttend" :on-no="actionCancel"/>
    </div>
</template>

<script>
    import axios from 'axios';
    import AlertBox from "./AlertBox";
    import App from 'App';

    export default {
        components: {AlertBox},
        data: function () {
            return {
                username: '',
                name: '',
                emptyText: '目前没有开放的考试',
                examsData: [],
                visibility: false,
                message: '',
                targetExamId: -1
            };
        },
        mounted() {
            this.username = this.$cookies.get('username');
            axios.post('/exams/', {
                intent: 'list',
                username: this.username
            })
            .then(res => {
                if (res.data.errorcode !== 0) {
                    return;
                }
                this.examsData = res.data.response
            });
        },
        methods: {
            tableTransparentApplier() {
                return 'background-color: #FCFAF2;';
            },
            actionSelectExam(id, name) {
                this.targetExamId = id;
                this.message = "确认参加「" + name + "」考试吗？";
                this.visibility = true;
            },
            actionAttend() {
                let sessionId = this.$cookies.get('session');

                axios.post('/exams/', {
                    intent: 'start',
                    session_id: sessionId,
                    exam_id: this.targetExamId,
                    username: this.username
                })
                .then(res => {
                    this.$router.push('/overview/aoligei');
                });
            },
            actionCancel() {
                this.visibility = false;
            }
        }
    };
</script>
