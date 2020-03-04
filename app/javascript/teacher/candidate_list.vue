<template>
    <div>
        <genreal-table-viewer table-name="考生" controller-name="users" :data="data" :search-filter="filter"/>

    </div>
</template>

<script>
    import GenrealTableViewer from './GenrealTableViewer';
    export default {
        components: { GenrealTableViewer },
        data: function() {
            return {
                data: [
                    { key: 'username', label: '学号', width: '140px' },
                    { key: 'name', label: '姓名' },
                    { key: 'institute', label: '学院', width: '140px' },
                    { key: 'major', label: '专业', width: '150px' },
                    { key: 'password', label: '初始密码' }
                ]
            };
        },
        methods: {
            filter(row, keyword) {
                if (!keyword)
                    return true;
                return row.username.toLowerCase().includes(keyword.toLowerCase())
                    || row.name.toLowerCase().includes(keyword.toLowerCase())
                    || row.institute.toLowerCase().includes(keyword.toLowerCase())
                    || row.major.toLowerCase().includes(keyword.toLowerCase());
            }
        }
    }
</script>
