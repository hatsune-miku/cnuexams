<template style="width: 100%;">
    <div>
        <div class="popup-div-wrapper" @click="actionCancel" v-if="visibility" style="z-index: 4;">
            <div :class="'popup-div ' + (mobile ? 'popup-div-mobile' : 'popup-div-pc')" @click.stop="dummyMethod">
                <h3>{{title}}</h3>

                <slot/>

                <el-scrollbar :class="mobile ? 'mobile-scroll-bar' : ''">
                    <el-container v-if="!property.uninputable && property.givenValue === undefined"
                                  direction="horizontal"
                                  v-for="(property, index) in properties"
                                  :key="property.key">

                        <el-input v-if="property.type === undefined"
                                  :readonly="property.readonly"
                                  :placeholder="property.label"
                                  v-model="inputs[index]"
                                  :show-password="property.password"
                                  style="margin-top: 10px;"
                                  :id="'input' + index">

                        <span slot="append" v-if="property.suffix !== undefined">
                            {{property.suffix}}
                        </span>

                        <span slot="prepend" v-if="property.prefix !== undefined">
                            {{property.prefix}}
                        </span>

                        </el-input>

                        <table v-if="property.type === 'number'" style="margin-top: 10px;">
                            <tr><td>
                            <span style="color: rgb(193, 196, 203); font-size: 14px; margin-top: 10px; width: 40%; float: left;">
                                {{property.label}}
                            </span>
                                <el-input-number v-model="inputs[index]"
                                                 style="width: 60%; float: right;"
                                                 :min="1"
                                                 :max="1300000000"
                                                 :id="'input' + index"/>
                            </td></tr>
                        </table>

                        <el-date-picker v-if="property.type === 'datetime'"
                                        style="margin-top: 10px; width: 100%;"
                                        v-model="inputs[index]"
                                        type="datetime"
                                        :placeholder="property.label"/>

                        <el-select v-if="property.type === 'multi-select'"
                                   style="margin-top: 10px; width: 100%;"
                                   v-model="inputs[index]"
                                   multiple
                                   :placeholder="property.label">
                            <el-option v-for="option in property.params"
                                       :label="option.name"
                                       :value="option.name"
                                       :key="option.name"/>
                        </el-select>

                        <el-select v-if="property.type === 'single-select'"
                                   style="margin-top: 10px; width: 100%;"
                                   v-model="inputs[index]"
                                   :placeholder="property.label">
                            <el-option v-for="option in property.params"
                                       :label="option.name"
                                       :value="option.value"
                                       :key="option.name"/>
                        </el-select>

                    </el-container>
                </el-scrollbar>


                <p v-if="comment !== undefined" style="font-size: 14px;">
                    {{comment}}
                </p>

                <table align="center" v-if="!buttonMode">
                    <tr>
                        <td>
                            <el-button type="primary" size="medium"
                                       @click="actionConfirm"
                                       style="width: 100px;">确认</el-button>
                        </td>

                        <td v-if="onDeleted !== undefined">
                            <el-button type="danger" size="medium"
                                       @click="actionDelete"
                                       style="width: 100px;">删除</el-button>
                        </td>
                    </tr>
                </table>

            </div>
        </div>

        <div class="alertback" style="z-index: 3;" v-if="visibility"></div>
    </div>
</template>

<script>
    export default {
        props: {
            title: {
                type: String
            },
            properties: {
                type: Array
            },
            visibility: {
                type: Boolean,
                default: false
            },
            onCancelled: {
                type: Function
            },
            onConfirmed: {
                type: Function
            },
            initValue: {
                type: Object,
                default: () => {return {};}
            },
            comment: {
                type: String,
                default: ''
            },
            onDeleted: {
                type: Function
            },
            mobile: {
                type: Boolean,
                default: false
            },
            buttonMode: {
                type: Boolean,
                default: false
            }
        },
        data: function () {
            return {
                inputs: [],
                shouldUpdate: true
            };
        },
        created() {

        },
        updated() {
            // appeared.
            if (!this.visibility || !this.shouldUpdate)
                return;
            this.shouldUpdate = false;

            if (this.buttonMode)
                return;

            this.properties.forEach((property, index) => {
                this.$set(this.inputs, index, this.initValue[property.key] || (property.defaultValue || ''));
            });

            setTimeout(() => {
                document.getElementById('input1').focus();
            }, 300);
        },
        destroyed() {
            this.shouldUpdate = true;
        },
        methods: {
            actionCancel() {
                this.shouldUpdate = true;
                this.onCancelled();
            },
            actionConfirm() {
                // convert.
                let res = {};
                this.properties.forEach((property, index) => {
                    res[property.key] = this.inputs[index];
                    this.inputs[index] = '';
                });
                this.onConfirmed(res);
            },
            actionDelete() {
                // convert.
                let res = {};
                this.properties.forEach((property, index) => {
                    res[property.key] = this.inputs[index];
                    this.inputs[index] = '';
                });
                this.onDeleted(res);
            },
            dummyMethod() {

            }
        }
    };
</script>
