<template>
    <div style="width: 100%; height: 100%;">
        <div v-if="ongoingExam">
            <el-container v-loading="loading"
                          element-loading-text="Now Loading..."
                          element-loading-spinner="el-icon-loading"
                          element-loading-background="rgba(0, 0, 0, 0.8)">

                <el-aside id="button-area" class="button-area"
                          style="width: fit-content; height: fit-content;">

                    <el-scrollbar style="height: fit-content; max-height: 295px;" :noresize="true">
                        <template v-for="(_, index) in questions">
                            <div class="question-button advanced-el-button"
                                 :style="index === currentIndex ? 'background: #ec8aaa;' : 'background: white;'"
                                 @click="switchQuestion(index)">
                                {{index + 1}}
                            </div>
                            <br v-if="(1 + index) % 4 === 0"/>
                        </template>
                    </el-scrollbar>

                    <br/>

                    <el-container aria-orientation="horizontal">
                        <el-button type="primary" size="mini" @click="actionSubmit">交卷</el-button>
                        <el-button size="mini" @click="actionLastQuestion"><</el-button>
                        <el-button size="mini" @click="actionNextQuestion">></el-button>

                        <!--
                        <div style="width: 100%; text-align: center; margin-top: 5px;">
                            <b>{{timeRemaining}}</b>
                        </div>
                        -->

                    </el-container>
                </el-aside>

                <el-main style="width: fit-content;">
                    <h4 style="color: #8c939d;">2 分，随机题，单选</h4>
                    <el-input class="summary-area" type="textarea" v-model="currentSummary"
                              :autosize="true" :readonly="true" style="width: 90%;"/>

                    <selection-item :on-clicked="actionSelectionUpdated"
                                    :question-index="currentIndex"
                                    :on-finished-loading="onFinishedLoading"
                                    :on-update-no-question-flag="onUpdateNoQuestionFlag"/>
                </el-main>

            </el-container>

            <alert-box :visibility="visibility" message="确认要交卷了吗？" :on-yes="performSubmit" :on-no="actionCancel"/>
            <scoreboard :data="scoreboardData" :visibility="shouldShowScoreboard" :on-yes="actionCancel" :on-no="actionCancel"/>
        </div>

        <div v-if="!ongoingExam" class="main-div">
            <h3>你目前还没参加任何考试</h3>
            <el-button size="medium" style="width: 200px;" type="primary"
                       @click.native="performSwitchToExamsList">查看可参加的考试</el-button>
        </div>
    </div>
</template>

<style scoped>
    .question-button {
        text-align: center;
        margin: 0 0 2px;
        width: 35px;
        font-size: 12px;
        font-weight: bold;
        height: 24px;
        line-height: 24px;
    }

    .button-area {
        border-radius: 10px;
        background: white;
        align-items: center;
        padding: 10px;
        border: rgb(221, 223, 230) solid 1px;
    }
</style>

<script>
    import SelectionItem from "./SelectionItem";
    import axios from 'axios';
    import AlertBox from "./AlertBox";
    import Scoreboard from "./scoreboard";

    export default {
        components: { Scoreboard, AlertBox, SelectionItem },
        data: function () {
            return {
                loading: true,
                questions: [],
                answers: [],
                currentSummary: "",
                currentIndex: 0,
                visibility: false,
                shouldShowScoreboard: false,
                scoreboardData: [],
                ongoingExam: true
            };
        },
        created() {

        },
        methods: {
            performSubmit() {
                // make array.
                let answers = [];
                for (let i = 0; i < this.questions.length; i++) {
                    let question = this.questions[i];

                    if (question.kind === 0) {
                        let index = question.options.split('##').indexOf(this.answers[i]);
                        answers.push(index.toString());
                    }
                    else {
                        if (this.answers[i].length === 0)
                            answers.push('-1');

                        else {
                            let subarray = '';
                            for (let a of this.answers[i]) {
                                console.log(a);

                                let index = question.options.split('##').indexOf(a);
                                if (index === -1)
                                    break;

                                subarray += index.toString();
                            }
                            answers.push(subarray);

                        }
                    }
                }

                console.log(answers);

                axios.post('/exams/', {
                    intent: 'judge',
                    session_id: this.$cookies.get('session'),
                    username: this.$cookies.get('username'),
                    answers: answers.join('##')
                })
                .then(res => {
                    let result = res.data.response;
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
                            value: result.hit + ' 题'
                        },
                        {
                            key: '答错',
                            value: result.miss + ' 题'
                        },
                        {
                            key: '成绩',
                            value: result.score + ' 分'
                        },
                        {
                            key: '是否通过',
                            value: result.passed ? 'Yes' : 'No'
                        }
                    ];
                    this.shouldShowScoreboard = true;
                });
            },
            answerArraySerialized(answers) {
                let ret = [];

                for (let i = 0; i < this.questions.length; i++) {
                    let ans = answers[i];

                    if (this.questions[i].kind === 1) {
                        // multi.
                        let ansStr = '';
                        if (ans) {
                            for (let a of ans) {
                                let index = this.questions[i].options.split('##').indexOf(a);

                                if (index === -1)
                                    break;

                                ansStr += index.toString();
                            }
                        }
                        ret.push(ansStr);
                    }
                    else {
                        // single.
                        ret.push(this.questions[i].options.split('##').indexOf(ans));
                    }
                }

                return ret.join(',');
            },
            performSaveStatus() {
                axios.post('/exams/', {
                    intent: 'save_status',
                    session_id: this.$cookies.get('session'),
                    username: this.$cookies.get('username'),
                    current_answers: this.answerArraySerialized(this.answers)
                });
            },
            performSwitchToExamsList() {
                this.$router.push('/overview/exams');
            },
            actionSubmit() {
                this.visibility = true;
            },
            actionCancel() {
                this.visibility = false;
                this.shouldShowScoreboard = false;
            },
            actionSelectionUpdated(items) {
                // saved status.
                this.answers = items;
                this.performSaveStatus();
            },
            actionNextQuestion() {
                if (this.currentIndex === this.questions.length - 1)
                    return;
                this.switchQuestion(this.currentIndex + 1);
            },
            actionLastQuestion() {
                if (this.currentIndex === 0)
                    return;
                this.switchQuestion(this.currentIndex - 1);
            },
            switchQuestion(index) {
                this.currentIndex = index;
                this.currentSummary = this.questions[index].summary;
            },
            onFinishedLoading(questions) {
                this.loading = false;
                this.questions = questions;

                this.switchQuestion(0);
            },
            onUpdateNoQuestionFlag(flag) {
                this.ongoingExam = flag === true;
            }
        }
    };
</script>
