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

                    <!-- right -->
                    <table style="float: right;">
                        <tr>

                            <td style="width: 30px;">

                            </td>

                            <td>
                                <el-button size="mini"
                                           @click.native="actionLogout"
                                           round>
                                    退出登录
                                </el-button>
                            </td>
                        </tr>
                    </table>
                </div>
            </el-header>

            <el-container style="height: 100%;">
                <el-aside style="width: 15%; min-width: fit-content;">
                    <el-menu router :default-active="$route.path"
                             style="height: 100%;"
                             background-color="#1b1b1b"
                             text-color="#ffffff"
                             active-text-color="#ffd04b">

                        <el-submenu index="1">
                            <template slot="title">
                                <i class="el-icon-location"></i>
                                <span>考生管理</span>
                            </template>

                            <el-menu-item index="/member/overview/spacelens">
                                <span slot="title"><i class="el-icon-menu"></i>考试概览</span>
                            </el-menu-item>

                            <el-menu-item index="/member/overview/candidate-list">
                                <span slot="title"><i class="el-icon-menu"></i>编辑考生列表</span>
                            </el-menu-item>

                            <el-menu-item index="/member/overview/candidate-auth">
                                <span slot="title"><i class="el-icon-menu"></i>授权码</span>
                            </el-menu-item>

                            <el-menu-item index="/member/overview/candidate-settings" v-if="false">
                                <span slot="title"><i class="el-icon-menu"></i>考生全局设置</span>
                            </el-menu-item>
                        </el-submenu>

                        <el-menu-item index="/member/overview/questions">
                            <span slot="title"><i class="el-icon-menu"></i>题库管理</span>
                        </el-menu-item>

                        <el-menu-item index="/member/overview/exams">
                            <span slot="title"><i class="el-icon-menu"></i>考试管理</span>
                        </el-menu-item>

                        <el-submenu index="2">
                            <template slot="title">
                                <i class="el-icon-location"></i>
                                <span>学院管理</span>
                            </template>
                            <el-menu-item index="/member/overview/institute-list">
                                <span slot="title"><i class="el-icon-menu"></i>学院列表和文理比例</span>
                            </el-menu-item>

                            <el-menu-item index="/member/overview/institute-settings">
                                <span slot="title"><i class="el-icon-menu"></i>文理比例批量设置</span>
                            </el-menu-item>
                        </el-submenu>

                        <el-menu-item index="/member/overview/about">
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
                timeRemaining: 0
            };
        },
        created() {
        },
        mounted() {
            this.username = this.$cookies.get('username');
            this.name = this.$cookies.get('name');

            this.$router.push('/member/overview/spacelens');

            this.timer = setInterval(this.timeTick, 1000);
        },
        beforeDestroy() {
            clearInterval(this.timer);
        },
        methods: {
            actionLogout() {
                this.visibility = true;
            },
            actionCancel() {
                this.visibility = false;
            },
            performLogout() {
                utils.removeReusedSession(this);
                window.location.href = '/member';
            }
        }
    }
</script>
