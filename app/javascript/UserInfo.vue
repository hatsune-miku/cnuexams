<template>
    <div>
        <div style="text-align: left;">

            <h2>个人信息</h2>

            <el-table :data="userdata" style="border-radius: 5px; width: 80%;" :show-header="false"
                      :header-cell-style="tableTransparentApplier" :row-style="tableTransparentApplier"
                      v-loading="userdataLoading"
                      element-loading-text="Now Loading..."
                      element-loading-spinner="el-icon-loading"
                      element-loading-background="rgba(0, 0, 0, 0.8)">
                <el-table-column prop="key" label="属性" width="200px"/>
                <el-table-column prop="value" label="值"/>
            </el-table>

            <br/>
            <h2>我的考试历史</h2>

            <el-table class="clickable-table" :data="displayData" style="border-radius: 5px; width: 80%;"
                      :header-cell-style="tableTransparentApplier" :row-style="tableTransparentApplier"
                      :empty-text="emptyText" @row-click="actionViewExamDetail"
                      v-loading="historyLoading"
                      element-loading-text="Now Loading..."
                      element-loading-spinner="el-icon-loading"
                      element-loading-background="rgba(0, 0, 0, 0.8)">
                <el-table-column prop="time" label="时间" width="220px"/>
                <el-table-column prop="examName" label="考试名称" width="260px"/>
                <el-table-column prop="score" label="考试成绩" width="90px">
                    <span slot-scope="scope">
                        {{scope.row.score + ' 分'}}
                    </span>
                </el-table-column>
                <el-table-column prop="passedOrNot" label="是否及格"/>
            </el-table>
            <br/>
            <el-pagination :hide-on-single-page="true"
                           @current-change="currentPageChange"
                           layout="total, prev, pager, next, jumper"
                           :page-size="3" :total="historydata.length"/>

            <br/>
            <h2>快捷操作</h2>

            <el-button @click="actionGoExams">参加一个考试</el-button>
            <el-button type="primary" @click="actionGoExam">回到正在进行的考试</el-button>
        </div>

        <scoreboard :data="scoreboardData" :visibility="shouldShowScoreboard"
                    :on-ok="actionCancel" :cancellable="true"/>
    </div>
</template>

<style scoped>
    /deep/ .clickable-table .el-table__row:hover {
        cursor: pointer;
    }
    /deep/ .btn-prev {
        background: transparent;
    }
    /deep/ .btn-prev:disabled {
        background: transparent;
    }
    /deep/ .btn-next {
        background: transparent;
    }
    /deep/ .btn-next:disabled {
        background: transparent;
    }
    /deep/ .el-pager {
        background: transparent;
    }
    /deep/ .number {
        background: transparent;
    }
    /deep/ .more {
        background: transparent;
    }
</style>

<script>
    import axios from 'axios';
    import Scoreboard from "./scoreboard";

    export default {
        components: { Scoreboard },
        data: function() {
            return {
                username: '',
                name: '',
                emptyText: '还没有参加过考试',
                userdata: [],
                historydata: [],
                displayData: [],
                shouldShowScoreboard: false,
                scoreboardData: [],
                userdataLoading: true,
                historyLoading: true
            };
        },
        mounted() {
            this.initUserData();
        },
        methods: {
            initUserData() {
                this.username = this.$cookies.get('username');

                axios.post('/users/', {
                    intent: 'info',
                    username: this.username
                }).then(res => {
                    if (res.data.errorcode !== 0) {
                        return;
                    }

                    // set global var.
                    this.globals.currentUser = res.data.response;

                    this.userdata = [
                        { key: '学号', value: this.username },
                        { key: '姓名', value: res.data.response.name },
                        { key: '学院', value: res.data.response.institute },
                        { key: '专业', value: res.data.response.major },
                    ]
                }).finally(() => {
                    this.userdataLoading = false;
                });

                axios.post('/users/', {
                    intent: 'history',
                    username: this.username
                }).then(res => {
                    if (res.data.errorcode !== 0) {
                        return;
                    }
                    this.historydata = res.data.response;
                }).finally(() => {
                    this.historyLoading = false;
                    this.currentPageChange(1);
                });
            },
            actionViewExamDetail(row) {
                let history = null;
                for (let i = 0; i < this.historydata.length; i++) {
                    if (row.id === this.historydata[i].id) {
                        history = this.historydata[i];
                        break;
                    }
                }
                if (history == null)
                    return;

                this.scoreboardData = [
                    {
                        key: '学号',
                        value: this.$cookies.get('username')
                    },
                    {
                        key: '姓名',
                        value: this.$cookies.get('name')
                    },
                    {
                        key: '答对',
                        value: history.hit + ' 题'
                    },
                    {
                        key: '答错',
                        value: history.miss + ' 题'
                    },
                    {
                        key: '成绩',
                        value: history.score + ' 分'
                    },
                    {
                        key: '用时',
                        value: this.secondTranslate(history.time_elapsed)
                    },
                    {
                        key: '是否通过',
                        value: history.passed ? 'Yes' : 'No'
                    }
                ];
                this.shouldShowScoreboard = true;
            },
            tableTransparentApplier() {
                return 'background-color: #FCFAF2;';
            },
            actionGoExam() {
                this.$router.push('/overview/aoligei');
            },
            actionGoExams() {
                this.$router.push('/overview/exams');
            },
            actionCancel() {
                this.shouldShowScoreboard = false;
            },
            currentPageChange(page) {
                let startIndex = 3 * (page - 1);
                this.displayData = this.historydata.slice(startIndex, startIndex + 3);
            }
        }
    };
</script>
