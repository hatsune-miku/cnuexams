<template>
    <div class="main-div">
        <h2>CNU Exams</h2>
        <h1 @click="actionAbout">首都师范大学信息工程学院</h1>
    </div>
</template>

<style scoped>
    .about-div {

    }
</style>

<script>
    export default {
        methods: {
            actionAbout() {
                alert("关于开发者\n" +
                    "wechat: a1knla\n" +
                    "wechat: lxt1025");
            }
        }
    }
</script>
