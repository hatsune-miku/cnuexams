<template>
    <el-container style="width: 90%;">

        <el-radio-group v-if="questions[questionIndex].kind !== 1"
                        v-model="savedAnswers[questionIndex]" style="width: 100%;">
            <!-- having margin-left = 0 set can fix this stupid bug. -->
            <el-radio v-for="(option, index) in questions[questionIndex].options.split('##')" :label="option"
                      :key="'radio-' + questionIndex + index" class="selection-item"
                      :style="'margin-left: 0; ' + (viewMode ? (
                            'background-color: ' + correctJudger(index) + ';'
                      ) : '')"
                      border @change="onClicked(savedAnswers)">
                <div class="radio-inner-wrapper">{{option}}</div>
            </el-radio>
        </el-radio-group>

        <el-checkbox-group v-if="questions[questionIndex].kind === 1"
                           v-model="savedAnswers[questionIndex]" style="width: 100%;">
            <!-- having margin-left = 0 set can fix this stupid bug. -->
            <el-checkbox v-for="(option, index) in questions[questionIndex].options.split('##')" :label="option"
                         :key="'check-' + questionIndex + index" class="selection-item"
                         :style="'margin-left: 0; ' + (viewMode ? (
                            'background-color: ' + correctJudger(index) + ';'
                      ) : '')"
                         border @change="onClicked(savedAnswers)">
                {{option}}
            </el-checkbox>
        </el-checkbox-group>

    </el-container>
</template>

<style scoped>
    .radio-inner-wrapper {
        display: inline-block;
        height: fit-content;
        width: 90%;
    }

    /deep/ .el-checkbox__label {
        word-break: break-all;
        white-space: normal;
        overflow: hidden;
        font-weight: bold;
    }

    /deep/ .el-radio__label {
        word-break: break-all;
        white-space: normal;
        overflow: hidden;
        font-weight: bold;
    }

    /deep/ .el-radio {
        padding-bottom: 10px;
    }

    /deep/ .el-checkbox {

    }

    /deep/ .is-bordered {
        height: fit-content;
    }

    /deep/ .el-checkbox__input {
    }

    /deep/ .el-radio__input {

    }
</style>

<script>
    import axios from 'axios';

    export default {
        data: function() {
            return {
                questions: [{ options: '' }],
                savedAnswers: []
            }
        },
        created() {
            axios.post('/exams/', {
                intent: 'restart',
                session_id: this.$cookies.get('session'),
                username: this.$cookies.get('username')
            })
            .then(res => {
                if (res.data.message === '无题目' || !res.data.response) {
                    this.onUpdateNoQuestionFlag(false);
                    return;
                }

                this.onUpdateNoQuestionFlag(true);

                let questions = res.data.response.questions;
                this.questions = [];

                for (let question of questions) {
                    this.questions.push({
                        id: question.id,
                        summary: question.summary,
                        options: question.options,
                        score: question.score,
                        essential: question.essential,
                        kind: question.kind,
                        cate: question.cate
                    });
                }

                let answers = res.data.response.saved_answers;

                if (answers.length === 0) {
                    console.log('initialize answer storage for first attendance.');
                    this.savedAnswers = this.answerArrayDeserialized(Array(this.questions.length).join(','));
                }
                else {
                    this.savedAnswers = this.answerArrayDeserialized(res.data.response.saved_answers);
                    console.log('restarted from storage.');
                }

                // sync saved answers to Aoligei.
                this.onClicked(this.savedAnswers);

                // can close loading now.
                this.onFinishedLoading(this.questions);
            });
        },
        mounted() {
        },
        props: {
            onClicked: {
                type: Function
            },
            questionIndex: {
                type: Number,
                default: 0
            },
            onFinishedLoading: {
                type: Function
            },
            onUpdateNoQuestionFlag: {
                type: Function
            },
            onAnswersRecovered: {
                type: Function
            },
            viewMode: {
                type: Boolean
            },
            correctJudger: {
                type: Function
            }
        },
        methods: {
            answerArrayDeserialized(answersRaw) {
                let ans = answersRaw.split(',');
                let ret = [];

                for (let i = 0; i < ans.length; i++) {
                    let flagSingle = this.questions[i].kind === 0;

                    if (flagSingle) {
                        ret.push(this.questions[i].options.split('##')[ans[i]]);
                    }
                    else {
                        let subarray = [];
                        for (let index of ans[i])
                            subarray.push(this.questions[i].options.split('##')[index]);
                        ret.push(subarray);
                    }
                }

                return ret;
            }
        }
    }
</script>
