<template>
    <div>
        <div style="text-align: left;">
            <h1>个人信息</h1>
            <el-table :data="userdata" style="border-radius: 5px; width: 80%;"
                      :header-cell-style="tableTransparentApplier" :row-style="tableTransparentApplier">
                <el-table-column prop="key" label="属性" width="200px"/>
                <el-table-column prop="value" label="值"/>
            </el-table>

            <br/>
            <h1>我的考试历史</h1>
            <el-table class="clickable-table" :data="historydata" style="border-radius: 5px; width: 80%;"
                      :header-cell-style="tableTransparentApplier" :row-style="tableTransparentApplier"
                      :empty-text="emptyText" @row-click="actionViewExamDetail">
                <el-table-column prop="time" label="时间" width="220px"/>
                <el-table-column prop="examName" label="考试名称" width="260px"/>
                <el-table-column prop="score" label="考试成绩" width="90px"/>
                <el-table-column prop="passedOrNot" label="是否及格"/>
            </el-table>

            <br/>
            <h1>快捷操作</h1>
            <el-button @click="actionGoExams">参加一个考试</el-button>
            <el-button type="primary" @click="actionGoExam">回到正在进行的考试</el-button>
        </div>
    </div>
</template>

<style scoped>
    /deep/ .clickable-table .el-table__row:hover {
        cursor: pointer;
    }
</style>

<script>
    import axios from 'axios';

    export default {
        data: function() {
            return {
                username: '',
                name: '',
                emptyText: '还没有参加过考试',
                userdata: [],
                historydata: []
            };
        },
        mounted() {
            this.username = this.$cookies.get('username');

            axios.post('/users/', {
                intent: 'info',
                username: this.username
            })
            .then(res => {
                if (res.data.errorcode !== 0) {
                    return
                }
                this.userdata = [
                    { key: '学号', value: this.username },
                    { key: '姓名', value: res.data.response.name },
                    { key: '学院', value: res.data.response.institute },
                    { key: '专业', value: res.data.response.major },
                    { key: '今日登录次数', value: res.data.response.limit }
                ]
            });

            axios.post('/users/', {
                intent: 'history',
                username: this.username
            })
            .then(res => {
                if (res.data.errorcode !== 0) {
                    return
                }
                this.historydata = res.data.response;
            });
        },
        methods: {
            actionViewExamDetail(row) {
                console.log(row);
            },
            tableTransparentApplier() {
                return 'background-color: #FCFAF2;';
            },
            actionGoExam() {
                this.$router.push('/overview/aoligei');
            },
            actionGoExams() {
                this.$router.push('/overview/exams');
            }
        }
    };
</script>
