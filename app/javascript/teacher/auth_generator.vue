<template>
    <div>
        <el-container aria-orientation="horizontal" style="margin: 10px;">
            <table style="width: 100%;">
                <tr>
                    <td align="left">
                        <el-button size="small" icon="el-icon-plus" type="danger" @click="actionGenerateAuthCode">
                            生成授权码
                        </el-button>
                    </td>
                    <td align="right">
                        <el-button size="medium" type="text" icon="el-icon-info" @click="actionShowIntro">什么是授权码？</el-button>
                    </td>
                </tr>
            </table>
        </el-container>

        <el-table :data="items"
                  @row-click="onRowClicked"
                  :row-style="tableTransparentApplier"
                  :header-cell-style="tableTransparentApplier"
                  v-loading="loading"
                  element-loading-text="Now Loading..."
                  element-loading-spinner="el-icon-loading"
                  element-loading-background="rgba(0, 0, 0, 0.8)">
            <el-table-column prop="authorizer" label="我发放的授权码"/>
            <el-table-column prop="authorizee" label="被授权人"/>
            <el-table-column prop="auth_code" label="授权码">
                <span slot-scope="scope" :data-clipboard-text="scope.row.auth_code" style="cursor: pointer;">
                    {{scope.row.auth_code}}
                </span>
            </el-table-column>
            <el-table-column width="90px">
                <span slot-scope="scope">
                    <el-button type="text" @click="actionRevoke(scope.row)">
                        <i style="font-size: 18px; color: gray;" class="el-icon-error"></i>
                    </el-button>
                </span>
            </el-table-column>
        </el-table>

        <property-editor :properties="properties"
                         :visibility="shouldShowPropertyEditor"
                         title="生成授权码"
                         :on-confirmed="actionConfirmed"
                         :on-cancelled="actionCancel"/>

    </div>
</template>

<script>
    import axios from 'axios'
    import PropertyEditor from "../PropertyEditor";
    import Clipboard from 'clipboard'

    export default {
        components: { PropertyEditor },
        data: function () {
            return {
                loading: false,
                items: [],
                shouldShowPropertyEditor: false,
                properties: [
                    { key: 'authorizee', label: '被授权人的学号' }
                ],
                intro: "考生因为各种原因无法再次参加某个考试时，如果有特殊情况需要参加，老师可以发放「授权码」使其能够额外参加一次考试。" +
                    "<br/><br/>注意事项:<br/>1. 授权码使用一次后失效。<br/>2. 授权码与考生绑定，张三的授权码李四不能用。"
            };
        },
        created() {
            this.performRefresh();
        },
        mounted() {
            new Clipboard('span').on('success', () => {
                this.$notify({ type: 'success', message: '已经复制授权码' });
            });
        },
        methods: {
            performRefresh() {
                this.loading = true;
                axios.post('/auths/', {
                    intent: 'list'

                }).then(res => {
                    this.items = res.data.response;

                }).finally(() => {
                    this.loading = false;
                });
            },
            tableTransparentApplier() {
                return 'background-color: #FCFAF2;';
            },
            actionGenerateAuthCode() {
                this.shouldShowPropertyEditor = true;
            },
            onRowClicked(row) {

            },
            actionConfirmed(auth) {
                this.shouldShowPropertyEditor = false;
                axios.post('/auths/', {
                    intent: 'create',
                    authorizee: auth.authorizee
                }).then(res => {
                    if (res.data.errorcode !== 0) {
                        this.$notify({ type: 'error', message: res.data.message });
                    }
                    else {
                        this.$notify({ type: 'success', message: res.data.message });
                        this.performRefresh();
                    }
                })
            },
            actionRevoke(auth) {
                axios.post('/auths/', {
                    intent: 'destroy',
                    auth_code: auth.auth_code
                }).then(() => {
                    this.performRefresh();
                });
            },
            actionCancel() {
                this.shouldShowPropertyEditor = false;
            },
            actionShowIntro() {
                this.$alert(this.intro, '授权码', { dangerouslyUseHTMLString: true });
            }
        }
    };
</script>
