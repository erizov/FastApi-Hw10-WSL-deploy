import { Button, Form, Input, Modal, Select } from "antd"
import { useState } from "react";
import { ManualButton } from "../ManualButton";
import { requestResume, requestVacancy } from "../requests";
import { useRequestData } from "../useRequestData";

const formatRecord = (data) => {
  return data;
}

const toOptions = (items)=>items.map(item=>({label: item.name, value: Number(item.key)})) 

export const ManualOrderModal = (props) => {
const {type='create', data, authRequest, loadData} = props;
  const [form] = Form.useForm();
  const [open, setOpen] = useState(false);
  const [confirmLoading, setConfirmLoading] = useState(false);

  const createRequest = (record) => authRequest('order/', {method:'post', data: record})
  const editRequest = (record) => authRequest(`order/${data.key}`, {method:'put', data: record})

  const request = (rawRecord) => {
    const record = formatRecord(rawRecord)
    switch (type) {
      case 'Create': return createRequest(record);
      case 'Edit': return editRequest(record);
    }
  } 

  const onSubmit = (rawRecord) => {
    setConfirmLoading(true);
    request(rawRecord).then(()=>{
      loadData()
    }).finally(()=>{
      setOpen(false);
      setConfirmLoading(false);
    })
  };

  return (
    <>
      <ManualButton type={type} onClick={()=>setOpen(true)}/>
      <Modal
        open={open}
        title={`${type} FAQ`}
        okText={type}
        cancelText="Cancel"
        okButtonProps={{ autoFocus: true, htmlType: 'submit' }}
        onCancel={() => setOpen(false)}
        destroyOnHidden
        confirmLoading={confirmLoading}
        modalRender={(dom) => (
          <Form
            layout="vertical"
            form={form}
            name="form_in_modal"
            clearOnDestroy
            onFinish={(values) => onSubmit(values)}
          >
            {dom}
          </Form>
        )}
      >
        <Form.Item
            label="Date"
            name="date"
            initialValue={data?.date ?? ''}
            >
            <Input />
            </Form.Item>
          <Form.Item
            label="Customer"
            name="customer"
            rules={[{ required: true, message: 'Please input Customer' }]}
            initialValue={data?.customer ?? ''}
            >
            <Input />
            </Form.Item>
          <Form.Item
            label="Phone"
            name="phone"
            initialValue={data?.phone ?? ''}
            >
            <Input />
            </Form.Item>
          <Form.Item
            label="Products"
            name="products"
            rules={[{ required: true, message: 'Please input Products' }]}
            initialValue={data?.products ?? ''}
            >
            <Input />
            </Form.Item>
          <Form.Item
            label="Sum"
            name="sum"
            rules={[{ required: true, message: 'Please input Sum' }]}
            initialValue={data?.sum ?? ''}
            >
            <Input />
            </Form.Item>
          <Form.Item
            label="Status"
            name="status"
            initialValue={data?.status ?? ''}
            >
            <Input />
            </Form.Item>
          <Form.Item
            label="Payment"
            name="payment"
            initialValue={data?.payment ?? ''}
            >
            <Input />
            </Form.Item>
          <Form.Item
            label="Delivery"
            name="delivery"
            initialValue={data?.delivery ?? ''}
            >
            <Input />
            </Form.Item>
          <Form.Item
            label="Track"
            name="track"
            initialValue={data?.track ?? ''}
            >
            <Input />
            </Form.Item>
      </Modal>
    </>
  );
};
