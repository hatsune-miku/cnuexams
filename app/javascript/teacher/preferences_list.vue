<template>
    <div>
        <genreal-table-viewer table-name="全局设置" controller-name="preferences" :data="data"
                              :search-filter="filter" :aliasor="aliasor"/>
    </div>
</template>

<script>
    import GenrealTableViewer from './GenrealTableViewer';
    export default {
        components: { GenrealTableViewer },
        data: function() {
            return {
                data: [
                    { key: 'id', uninputable: true, invisible: true },
                    { key: 'name', label: '属性', width: '200px', readonly: true },
                    { key: 'value', label: '值' }
                ]
            };
        },
        methods: {
            filter(row, keyword) {
                if (!keyword)
                    return true;
                for (let item of this.data)
                    if (row[item.key].toLowerCase().includes(keyword.toLowerCase()))
                        return true;
                return false;
            },
            aliasor(name) {
                return {
                    login_limit: '每日登录次数限制'
                }[name] || name;
            }
        }
    }
</script>
