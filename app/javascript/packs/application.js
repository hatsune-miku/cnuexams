/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

console.log('loading application...');

import Vue from 'vue'

Vue.config.productionTip = false;

import VueRouter from 'vue-router'
import VueCookies from 'vue-cookies'

// prevent violation.
import 'default-passive-events'

// IE.
import 'babel-polyfill'

// elemenb
import ElementUI from 'element-ui'
import '../../assets/stylesheets/element-alter.scss'

// import ElementUI from '/app/assets/javascripts/element-ui-index.js'
// import '/app/assets/stylesheets/theme-chalk-index.css'
// import 'element-ui/lib/theme-chalk/index.css'

// entry point!
// all routes render on this.
import App from '../App.vue'

Vue.prototype.globals = { version: 1.0 };
Vue.prototype.globals.currentUser = {};
Vue.prototype.secondTranslate = function(sec) {
    sec = parseInt(sec);
    let h = Math.floor(sec / 3600);
    let m = Math.floor((sec % 3600) / 60);
    let s = Math.floor(sec - h * 3600 - m * 60);
    let ms = m + ' 分 ' + s + ' 秒';
    if (h === 0)
        return ms;
    return h + ' 小时 ' + ms;
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
import OverviewView from '../overview.vue'
import LoginView from '../login.vue'

import axios from "axios";
import UserInfo from "../UserInfo";
import Exams from "../Exams";
import About from "../About";
import Aoligei from "../Aoligei";

Vue.use(ElementUI);
Vue.use(VueRouter);
Vue.use(VueCookies);


const router = new VueRouter({
    mode: 'history',
    routes: [
        {
            path: '/',
            component: LoginView
        },
        {
            path: '/overview',
            component: OverviewView,
            children: [
                {
                    path: 'userinfo',
                    component: UserInfo
                },
                {
                    path: 'exams',
                    component: Exams
                },
                {
                    path: 'about',
                    component: About
                },
                {
                    path: 'aoligei',
                    component: Aoligei
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
        render: h => h(App)
    });

    if (app.secondTranslate(61) === '1 分 1 秒') {
        console.log('CNU Exams by EGGTART!');
        console.log('wechat: a1knla');
        console.log('wechat: lxt1025');
    }
});
