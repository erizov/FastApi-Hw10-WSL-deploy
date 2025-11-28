import {  Flex,  Space, Table } from "antd"
import { ManualOrderModal } from "./ManualOrderModal";
import { DeleteOrderModal } from "./DeleteOrderModal";
import { useRequestData } from "../useRequestData";
import { requestOrders } from "../requests";

export const Order = (props) => {
  const {authRequest} = props;
  const {loading, loadData, items} = useRequestData(
    ()=>requestOrders(authRequest)
  )

const columns = [
  {
    title: 'Products',
    dataIndex: 'products',
    key: 'products',
  },
  {
    title: 'Sum',
    dataIndex: 'sum',
    key: 'sum',
  },
  {
    title: 'Status',
    dataIndex: 'status',
    key: 'status',
  },
{
    title: 'Action',
    key: 'action',
    render: (_, record) => (
      <Space size="middle">
        <ManualOrderModal type='Edit' data={record} authRequest={authRequest} loadData={loadData}/>
        <DeleteOrderModal id={record.key} loadData={loadData} authRequest={authRequest}/>
      </Space>
    ),
  },
];


    return <Flex vertical gap={16}>
            <Flex justify="flex-end" align="center">
                <Flex gap={8} align="center" style={{paddingRight:'16px'}}>
                      <ManualOrderModal type='Create' authRequest={authRequest} loadData={loadData}/>
                </Flex>
            </Flex>
            <Table loading={loading} pagination={false} columns={columns} dataSource={items}/>
    </Flex>
}