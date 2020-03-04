/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

console.log('loading member application...');

import Vue from 'vue'

// Vue.config.productionTip = false;

import VueRouter from 'vue-router'
import VueCookies from 'vue-cookies'

// prevent violation.
import 'default-passive-events'

// elemenb
import ElementUI from 'element-ui'
import '../../assets/stylesheets/element-alter.scss'

// vcharts
import VCharts from 'v-charts'

// import ElementUI from '/app/assets/javascripts/element-ui-index.js'
// import '/app/assets/stylesheets/theme-chalk-index.css'
// import 'element-ui/lib/theme-chalk/index.css'

// entry point!
// all routes render on this.
import TeacherApp from '../TeacherApp.vue'

Vue.prototype.globals = { version: 1.0 };
Vue.prototype.globals.currentUser = {};
Vue.prototype.secondTranslate = function(sec) {
    if (sec === '-' || sec === 0)
        return '-';
    sec = parseInt(sec);
    let h = Math.floor(sec / 3600);
    let m = Math.floor((sec % 3600) / 60);
    let s = Math.floor(sec - h * 3600 - m * 60);
    let ms = m + ' 分 ' + s + ' 秒';
    if (h === 0)
        return ms;
    return h + ' 小时 ' + ms;
};
Vue.prototype.timestampToTime = function(timestamp) {
    if (timestamp === 0)
        return '-';
    return new Date(parseInt(timestamp) * 1000)
        .toLocaleString('zh-cn', { hour12: false })
        .replace(/\//g, '-');
};
Vue.prototype.reinitUserData = function() {
    let username = this.$cookies.get('username');
    axios.post('/users/', {
        intent: 'info',
        username: username
    }).then(res => {
        if (res.data.errorcode !== 0) {
            return;
        }

        // set global var.
        this.globals.currentUser = res.data.response;
        console.log(this.globals.currentUser);
    });
};

// all windows.
import OverviewView from '../teacher/overview'
import LoginView from '../teacher/login'
import SpacelensView from '../teacher/spacelens'
import CandidateListView from '../teacher/candidate_list'
import ExamsView from '../teacher/exams_list'
import QuestionsView from '../teacher/questions_list'
import PreferencesListView from '../teacher/preferences_list'
import InstitutesListView from '../teacher/institute_list'
import AuthGeneratorView from '../teacher/auth_generator'
import InstitutesSetView from '../teacher/institute_set'
import AboutView from "../About"

import axios from "axios";

Vue.use(ElementUI);
Vue.use(VueRouter);
Vue.use(VueCookies);
Vue.use(VCharts);


const router = new VueRouter({
    mode: 'history',
    routes: [
        {
            path: '/member/login',
            component: LoginView
        },
        {
            path: '/member',
            component: LoginView
        },
        {
            path: '/member/overview',
            component: OverviewView,
            children: [
                {
                    path: '/member/overview/spacelens',
                    component: SpacelensView
                },
                {
                    path: '/member/overview/candidate-list',
                    component: CandidateListView
                },
                {
                    path: '/member/overview/exams',
                    component: ExamsView
                },
                {
                    path: '/member/overview/questions',
                    component: QuestionsView
                },
                {
                    path: '/member/overview/candidate-settings',
                    component: PreferencesListView
                },
                {
                    path: '/member/overview/institute-list',
                    component: InstitutesListView
                },
                {
                    path: '/member/overview/institute-settings',
                    component: InstitutesSetView
                },
                {
                    path: '/member/overview/candidate-auth',
                    component: AuthGeneratorView
                },
                {
                    path: '/member/overview/about',
                    component: AboutView
                }
            ]
        }
    ]
});

document.addEventListener('DOMContentLoaded', () => {

    let token = document.getElementsByName('csrf-token')[0].getAttribute('content');
    console.log('csrf-token: ' + token);
    axios.defaults.headers.common['X-CSRF-Token'] = token;

    const originalPush = VueRouter.prototype.push;
    VueRouter.prototype.push = function(location) {
        return originalPush.call(this, location).catch(err => err);
    };

    const app = new Vue({
        router: router,
        el: "#app",
        render: h => h(TeacherApp)
    });

    if (app.secondTranslate(61) === '1 分 1 秒') {
        console.log('CNU Exams by EGGTART!');
        console.log('wechat: a1knla');
        console.log('wechat: lxt1025');
    }
});
