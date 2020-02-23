<template>
    <div>
        <genreal-table-viewer table-name="学院" controller-name="institutes" :data="data" :search-filter="filter"/>
    </div>
</template>

<script>
    import GenrealTableViewer from './GenrealTableViewer';
    export default {
        components: { GenrealTableViewer },
        data: function() {
            return {
                data: [
                    { key: 'id', invisible: true, uninputable: true },
                    { key: 'name', label: '学院名称', width: '150px' },
                    { key: 'kind', label: '文or理', type: 'single-select', params: [
                            { name: '文', value: 1 },
                            { name: '理', value: 0 }
                        ]
                    },
                    { key: 'mathp', label: '理科题比例', postProcessor: this.percentageProcessor },
                    { key: 'artp', label: '文科题比例', postProcessor: this.percentageProcessor },
                    { key: 'generalp', label: '通用题比例', postProcessor: this.percentageProcessor }
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
            percentageProcessor(dat) {
                return (dat * 100.0).toFixed(0) + ' %';
            }
        }
    }
</script>
