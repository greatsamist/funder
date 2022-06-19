import styles from "./DonationDetail.module.scss";
import btn from "../../styles/button.module.scss";

import { useContext, useState, useRef, useEffect } from "react";
import { FunderAddr, FunderAbi } from "../../constants";
import { Web3Context } from "../../contexts/Web3Context";
import { Contract, ethers } from "ethers";

function DonationDetail(props) {
  const { provider, connect, wallet } = useContext(Web3Context);
  const [submitting, setSubmitting] = useState(false);
  const [amountGen, setAmountGen] = useState("0");
  const amountInputRef = useRef();
  const dateInputRef = useRef();

  //   var myDate = "20-06-2022";
  // myDate = myDate.split("-");
  // var newDate = new Date( myDate[2], myDate[1] - 1, myDate[0]);
  // console.log(newDate.getTime());

  // const enteredDate = dateInputRef.current.value;
  // console.log(enteredDate);

  const amountGenerated = async () => {
    if (!provider) {
      alert("connect wallet to mumbai network and try again");
      await connect();
      return;
    }
    const customProvider = new ethers.providers.JsonRpcProvider(
      process.env.ALCHEMY_URL
    );
    const signer = provider.getSigner();
    const FunderContractInstance = new Contract(FunderAddr, FunderAbi, signer);

    const genAmount = await FunderContractInstance.withdrawAll();

    const receipt = await genAmount.wait();
    console.log(receipt);
    // console.log(receipt);
  };

  // useEffect(() => {
  //  amountGenerated()

  // }, [onClickDonate])

  const onClickDonate = async (e) => {
    e.preventDefault();
    // const date = dateInputRef.current.value;
    // let myDate = new Date(date);
    // // let myDate = date;
    // // myDate = myDate.split("-");
    // // let newDate = new Date(myDate[0], myDate[1] - 1, myDate[2]);
    // console.log(myDate.getTime());

    console.log(amountInputRef.current.value);
    if (!provider) {
      alert("connect wallet to mumbai network and try again");
      await connect();
      return;
    }

    setSubmitting(true);
    const enteredAmount = amountInputRef.current.value;

    const signer = provider.getSigner();
    const FunderContractInstance = new Contract(FunderAddr, FunderAbi, signer);

    const Donation = await FunderContractInstance.donateFunds(
      props.address,
      {
        value: ethers.utils.parseEther(enteredAmount),
      }
    );

    const receipt = await Donation.wait(1);

    alert("Donation successfully");
    setSubmitting(false);
  };
  return (
    <section className={styles.detail}>
      <h2 className={styles.detail__heading}>Donate</h2>
      <div className={styles.detail__card}>
        <div className={styles.detail__image}>
          <img src={props.image} alt={props.name} />
        </div>
        <div className={styles.detail__content}>
          <div className={styles.detail__price}>
            <p className={styles.detail__totalPrice}>${props.amount}</p>
            <p className={styles.detail__curPrice}>${props.amount}</p>
          </div>
          <div className={styles.detail__name}>
            <h1>{props.name}</h1>
          </div>

          <p className={styles.detail__desc}>{props.desc}</p>
          <p>{props.period}</p>
          <div className={styles.detail__input}>
            <input
              className={styles.detail__num}
              required
              type="number"
              id="amount"
              placeholder="Input amount"
              ref={amountInputRef}
            />

            {/* <input
              className={styles.form__input}
              required
              name="date"
              id="date"
              type="date"
              min="1"
              ref={dateInputRef}
            />
          </div> */}
          <div>
            {!submitting ? (
              <button
                className={`${btn.btn} ${btn.btn__animated} ${btn.btn__primary} ${styles.detail__btn}`}
                onClick={onClickDonate}
              >
                Donate
              </button>
            ) : (
              ""
            )}
          </div>
        </div>
      </div>
    </section>
  );
}

export default DonationDetail;
