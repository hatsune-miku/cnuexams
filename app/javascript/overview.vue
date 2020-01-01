<template>
    <div class="fullscreeen">
        <el-container style="height: 100%;">
            <el-header class="header vmiddle-wrapper">
                <div class="vmiddle-div" style="color: white;">

                    <!-- left -->
                    <table style="float: left;">
                        <tr>
                            <td>CNU Exams - {{username}} {{name}}</td>
                        </tr>
                    </table>

                    <!-- middle -->
                    <table style="position: absolute; left: 50%; transform: translate(-50%, 0);">
                        <tr>
                            <td style="color: #8c939d;">
                                研究生学术不端测试 {{secondToTime(timeRemaining)}} 剩余
                            </td>

                            <td>
                                <el-progress :percentage="Math.floor(100.0 * timeRemaining / timeInitial)"
                                             :text-inside="true" :stroke-width="26"
                                             color="gray"
                                             style="width: 80px;"/>
                            </td>
                        </tr>
                    </table>

                    <!-- right -->
                    <table style="float: right;">
                        <tr>

                            <td style="width: 30px;">

                            </td>

                            <td>
                                <el-button size="mini"
                                           @click.native="actionLogout"
                                           round>退出登录</el-button>
                            </td>
                        </tr>
                    </table>
                </div>
            </el-header>

            <el-container style="height: 100%;">
                <el-aside style="width: 15%; min-width: fit-content;">
                    <el-menu router :default-active="$route.path" class="aside">

                        <el-menu-item index="/overview/aoligei">
                            <span slot="title"><i class="el-icon-menu"></i>正在进行的考试</span>
                        </el-menu-item>

                        <el-menu-item index="/overview/userinfo">
                            <span slot="title"><i class="el-icon-menu"></i>个人信息</span>
                        </el-menu-item>

                        <el-menu-item index="/overview/exams">
                            <span slot="title"><i class="el-icon-menu"></i>考试列表</span>
                        </el-menu-item>

                        <el-menu-item index="/overview/about">
                            <span slot="title"><i class="el-icon-menu"></i>关于</span>
                        </el-menu-item>

                    </el-menu>
                </el-aside>

                <el-main style="height: 100%;">
                    <router-view></router-view>
                </el-main>

            </el-container>
        </el-container>

        <alert-box :visibility="visibility" message="确认要注销吗？" :on-yes="performLogout" :on-no="actionCancel"/>

        <div class="fullscreeen-filter" style="z-index: -1; position: fixed;"></div>
    </div>
</template>

<style scoped>
    .aside {
        height: 100%;
        background: white;
    }
</style>

<script>
    import AlertBox from 'AlertBox';
    import axios from 'axios';
    import utils from 'utils';

    export default {
        components: { AlertBox },
        data: function () {
            return {
                username: '1171002076',
                name: '关镇',
                visibility: false,
                timer: '',
                timeInitial: 2 * 60 * 60,
                timeRemaining: 0
            };
        },
        created() {
            this.timeRemaining = this.timeInitial;
        },
        mounted() {
            this.username = this.$cookies.get('username');
            this.name = this.$cookies.get('name');

            this.$router.push('/overview/userinfo');

            this.timer = setInterval(this.timeTick, 1000);
        },
        beforeDestroy() {
            clearInterval(this.timer);
        },
        methods: {
            performSubmit() {

            },
            secondToTime(sec) {
                sec = parseInt(sec);
                let hr = Math.floor(sec / 3600);
                let mi = Math.floor((sec % 3600) / 60);
                let se = Math.floor(sec - hr * 3600 - mi * 60);

                if (mi < 10) mi = '0' + mi;
                if (se < 10) se = '0' + se;

                return hr + ':' + mi + ':' + se;
            },
            timeTick() {
                this.timeRemaining -= 1;

                if (this.timeRemaining <= 0) {
                    clearInterval(this.timer);
                    this.performSubmit();
                }
            },
            actionLogout() {
                this.visibility = true;
            },
            actionCancel() {
                this.visibility = false;
            },
            performLogout() {
                utils.removeReusedSession(this);
                window.location.href = '/';
            }
        }
    }
</script>
