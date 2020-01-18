<template>
    <div style="width: 100%; height: 100%;">
        <div v-if="ongoingExam">
            <el-container v-loading="loading"
                          element-loading-text="Now Loading..."
                          element-loading-spinner="el-icon-loading"
                          element-loading-background="rgba(0, 0, 0, 0.8)">

                <el-aside id="button-area" class="button-area"
                          style="width: fit-content; height: fit-content;">

                    <el-scrollbar noresize>
                        <template v-for="(question, index) in questions">

                            <span v-if="question.label !== ''">
                                <span v-if="index !== 0"><br/></span>
                                <span style="font-size: 14px; font-weight: bold; line-height: 40px; color: gray; position: relative; top: 3px;">
                                    {{question.label}}
                                </span>
                                <span v-if="question.label !== ''"><br/></span>
                            </span>

                            <div class="question-button advanced-el-button"
                                 :style="cellStyleAdapter(index)"
                                 @click="switchQuestion(index)">
                                {{index + 1}}
                            </div>
                            <br v-if="warpTable[index]"/>
                        </template>
                    </el-scrollbar>

                    <br/>

                    <el-container aria-orientation="horizontal">
                        <el-button type="primary" size="mini" @click="actionSubmit">{{viewMode ? '返回' : '交卷'}}</el-button>
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
                    <h4 style="color: #8c939d;">{{questionInfo()}}</h4>
                    <el-input class="summary-area" type="textarea" v-model="currentSummary"
                              :autosize="true" :readonly="true" style="width: 90%;"/>

                    <selection-item :on-clicked="actionSelectionUpdated"
                                    :question-index="currentIndex"
                                    :on-finished-loading="onFinishedLoading"
                                    :on-update-no-question-flag="onUpdateNoQuestionFlag"
                                    :view-mode="viewMode"
                                    :correct-judger="correctJudger"/>
                </el-main>

            </el-container>

            <alert-box :visibility="visibility" :message="messagePrefix + '确认要交卷了吗？'" :on-yes="performSubmit" :on-no="actionCancel"/>
            <scoreboard :data="scoreboardData" :visibility="shouldShowScoreboard"
                        :on-ok="actionScoreboardOk" :on-view-answer="onViewAnswer"/>
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
                ongoingExam: true,
                timer: '',
                realAnswers: [],
                viewMode: false,
                messagePrefix: '',
                warpTable: []
            };
        },
        created() {
            this.timer = setInterval(() => {
                if (this.globals.shouldSubmitNow === true) {
                    clearInterval(this.timer);
                    if (this.$router.currentRoute.path === '/overview/aoligei') {
                        this.globals.shouldSubmitNow = false;
                        this.performSubmit();
                    }
                }
            }, 500);
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
                                // console.log(a);

                                let index = question.options.split('##').indexOf(a);
                                if (index === -1)
                                    break;

                                subarray += index.toString();
                            }
                            answers.push(subarray);

                        }
                    }
                }

                axios.post('/exams/', {
                    intent: 'judge',
                    session_id: this.$cookies.get('session'),
                    username: this.$cookies.get('username'),
                    answers: answers.join('##')

                }).then(res => {
                    if (res.data.errorcode !== 0) {
                        this.$notify({ type: 'error', message: res.data.message });
                        this.$alert(res.data.message, 'CNU Exams', {
                            confirmButtonText: '好'
                        }).finally(() => {
                            this.$router.push('/overview/userinfo');
                        });
                        return;
                    }

                    let result = res.data.response;

                    this.realAnswers = result.ans;
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
                            key: '用时',
                            value: this.secondTranslate(result.time_elapsed)
                        },
                        {
                            key: '是否通过',
                            value: result.passed ? 'Yes' : 'No'
                        }
                    ];
                    this.shouldShowScoreboard = true;

                }).finally(() => {
                    this.reinitUserData();
                });
            },
            onViewAnswer() {
                this.viewMode = true;
                this.shouldShowScoreboard = false;
                this.visibility = false;
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
                // console.log(this.answerArraySerialized(this.answers));
                // console.log('saved.');
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
                let flagAllAnswered = true;
                for (let ans of this.answers) {
                    if (ans instanceof Array && ans.length === 0) {
                        flagAllAnswered = false;
                        break;
                    }
                    else if (ans === undefined) {
                        flagAllAnswered = false;
                        break;
                    }
                }
                this.messagePrefix = flagAllAnswered ? '' : '你还有题未答。';
                if (this.viewMode)
                    this.$router.push('/overview/userinfo');
                else
                    this.visibility = true;
            },
            actionCancel() {
                this.visibility = false;
            },
            actionScoreboardOk() {
                this.shouldShowScoreboard = false;
                this.$router.push('/overview/userinfo');
            },
            actionSelectionUpdated(items) {
                if (this.viewMode)
                    return;

                // saved status.
                this.answers = items;

                console.log(this.questions);

                if (this.questions.length !== 0)
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

                // calculate warp table.
                let counter = 1;
                for (let q of questions) {
                    if (counter % 4 === 0)
                        this.warpTable.push(true);
                    else
                        this.warpTable.push(false);

                    if (q.label !== '')
                        counter = 1;

                    counter++;
                }

                this.switchQuestion(0);

                if (this.globals.shouldSubmitNow === true) {
                    this.globals.shouldSubmitNow = false;
                    this.performSubmit();
                }
            },
            onUpdateNoQuestionFlag(flag) {
                this.ongoingExam = flag === true;
            },
            answerMatches(index) {
                let indexes = this.realAnswers[index].replace(/(.)(?=[^$])/g,"$1,").split(",");
                let arr = [];
                for (let i of indexes) {
                    arr.push(this.questions[index].options.split('##')[i]);
                }
                return arr.join('-') === (
                    this.answers[index] instanceof Array
                    ? this.answers[index].join('-')
                    : this.answers[index]
                );
            },
            correctJudger(index) {
                if (this.realAnswers[this.currentIndex].includes(index))
                    return 'green';
                else if (this.answers[this.currentIndex]
                    && this.answers[this.currentIndex].includes(this.questions[this.currentIndex].options.split('##')[index]))
                    return 'red';
                return 'transparent';
            },
            cellStyleAdapter(index) {
                if (this.viewMode) {
                    return this.answerMatches(index) ? 'background: white;' : 'background: red;';
                }

                // is current question?
                let background = (index === this.currentIndex)
                    ? '#EC8AAA'
                    : 'white';

                // is unanswered?
                let addition = (!this.answers[index] || this.answers[index].length === 0)
                    ? 'color: black;'
                    : 'background: #dfdfdf;';

                return `background: ${background}; ${addition}`;
            },
            questionInfo() {
                let question = this.questions[this.currentIndex];
                if (!question)
                    return '';


                let kind = question.kind === 0 || question.kind === 2 ? '单选' : '多选';
                let cate = ['理科题', '文科题', '通用-其它题', '通用-文件题', '通用-视频题'][question.cate];
                return `第 ${this.currentIndex + 1} 题，${question.score} 分，${cate}，${kind}`;
            }
        }
    };
</script>

